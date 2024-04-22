const express = require('express')
const app = express()
const server = require('http').createServer(app)
const io = require('socket.io')(server)
const jsonwebtoken = require('jsonwebtoken')
const { PrismaClient } = require('@prisma/client')
const { Resend } = require('resend')
const bcrypt = require('bcrypt')
const redis = require('redis')
const chess = require('chess.js')
const cors = require('cors')

require('dotenv').config({ path: './server.env' })
const secretKey = process.env.SECRET_KEY
const resendKey = process.env.RESEND_API_KEY
var redisUrl = process.env.REDIS_URL
const resendEmail = process.env.RESEND_EMAIL
const NODE_ENV = process.env.NODE_ENV
const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGIN

const prisma = new PrismaClient()
const resend = new Resend(resendKey)

if (NODE_ENV === 'development') {
  redisUrl = 'redis://localhost:6379'
}

const publisher = redis.createClient({
  url: redisUrl
})
const subscriber = publisher.duplicate()
const redisClient = publisher.duplicate()

var matchQueue = []

app.use(express.json())
app.use(
  cors({
    origin: true,
    credentials: true
  })
)

const generateResponse = (message, success, data) => {
  if (!success) {
    return {
      message,
      success
    }
  }
  return {
    message,
    success,
    data
  }
}

const sendVerificationEmail = async (email, token) => {
  await resend.emails.send({
    to: email,
    from: resendEmail,
    subject: 'Verify your email',
    html: `Click on the link to verify your email: <a href="http://chess-server.manangandhi.tech/rest/verify-email?token=${token}">Verify</a>`
  })
}

const generateNewGameState = (gameId, whiteUser, blackUser) => {
  const game = new chess.Chess()
  console.log('Game:', game.fen())
  return {
    gameId,
    whiteUser,
    blackUser,
    boardState: game.fen(),
    moves: [],
    status: 'In Progress'
  }
}

app.use(express.json())

app.post('/register', async (req, res) => {
  const { email, username, name, password } = req.body
  if (!email || !username || !name || !password) {
    return res.json(generateResponse('Please provide all fields', false, null))
  }
  const hashedPassword = bcrypt.hashSync(password, 10)
  var user
  try {
    user = await prisma.user.create({
      data: {
        email,
        username,
        name,
        password: hashedPassword
      }
    })
  } catch (e) {
    return res.json(
      generateResponse('Email or Username already exists', false, null)
    )
  }
  if (user) {
    const token = jsonwebtoken.sign({ id: user.id }, secretKey)
    sendVerificationEmail(user.email, token)
    user.password = undefined
    return res.json(
      generateResponse(
        'You have been registered succesfully, please verify your Email ID.',
        true,
        user
      )
    )
  }
  res.json(generateResponse('Something went wrong', false, null))
})

app.post('/login', async (req, res) => {
  const { email, password } = req.body
  if (!email || !password) {
    return res.json(generateResponse('Please provide all fields', false, null))
  }
  const user = await prisma.user.findFirst({
    where: {
      email
    }
  })
  if (!user) {
    return res.json(generateResponse('Invalid credentials', false, null))
  }
  if (!user.isVerified) {
    return res.json(
      generateResponse('Please verify your email to login', false, null)
    )
  }
  if (user) {
    const isPasswordValid = bcrypt.compareSync(password, user.password)
    if (!isPasswordValid) {
      return res.json(generateResponse('Invalid credentials', false, null))
    }
    user.password = undefined
    const token = jsonwebtoken.sign({ id: user.id }, secretKey)
    return res.json(
      generateResponse('You have been logged in successfully', true, {
        user,
        token
      })
    )
  }
  res.json(generateResponse('Invalid credentials', false, null))
})

app.get('/verify-email', async (req, res) => {
  const { token } = req.query
  if (!token) {
    return res.json(generateResponse('Invalid token', false, null))
  }
  const decoded = jsonwebtoken.verify(token, secretKey)
  if (decoded) {
    const user = await prisma.user.update({
      where: {
        id: decoded.id
      },
      data: {
        isVerified: true
      }
    })
    if (user) {
      return res.json(
        generateResponse(
          'Your email has been verified successfully',
          true,
          null
        )
      )
    }
  }
  res.json(generateResponse('Invalid token', false, null))
})

app.get('/resend-verification-email', async (req, res) => {
  const { email } = req.query
  if (!email) {
    return res.json(generateResponse('Please provide email', false, null))
  }
  const user = await prisma.user.findFirst({
    where: {
      email
    }
  })
  if (!user) {
    return res.json(generateResponse('User not found', false, null))
  }
  if (user.isVerified) {
    return res.json(generateResponse('Email already verified', false, null))
  }
  const token = jsonwebtoken.sign({ id: user.id }, secretKey)
  sendVerificationEmail(user.email, token)
  res.json(generateResponse('Verification email sent', true, null))
})

app.get('/getUser', async (req, res) => {
  const { authorization } = req.headers
  console.log(authorization)
  if (!authorization) {
    return res.json(
      generateResponse('Missing Authentication Header', false, null)
    )
  }
  const token = authorization.split(' ')[1]
  if (!token) {
    return res.json(generateResponse('Invalid token', false, null))
  }
  const decoded = jsonwebtoken.verify(token, secretKey)
  if (decoded) {
    const user = await prisma.user.findFirst({
      where: {
        id: decoded.id
      }
    })
    if (user) {
      user.password = undefined
      return res.json(generateResponse('User found', true, user))
    } else {
      return res.json(generateResponse('User not found', false, null))
    }
  }
})

app.get('/getUserData', async (req, res) => {
  const { id } = req.query
  if (!id) {
    return res.json(generateResponse('Please provide user ID', false, null))
  }
  const user = await prisma.user.findFirst({
    where: {
      id: id
    }
  })
  if (user) {
    user.password = undefined
    return res.json(generateResponse('User found', true, user))
  }
  res.json(generateResponse('User not found', false, null))
})

app.get('/getUserGames', async (req, res) => {
  const { id } = req.query
  if (!id) {
    return res.json(generateResponse('Please provide user ID', false, null))
  }
  const games = await prisma.game.findMany({
    where: {
      OR: [
        {
          whiteUserId: id
        },
        {
          blackUserId: id
        }
      ]
    }
  })
  if (games) {
    var res_games = []
    games.forEach(game => {
      game.gameId = game.id
      game.whiteUser = game.whiteUserId
      game.blackUser = game.blackUserId
      delete game.whiteUserId
      delete game.blackUserId
      delete game.id
      res_games.push(game)
    });
    return res.json(generateResponse('Games found', true, res_games))
  }
  res.json(generateResponse('Games not found', false, null))
})

io.on('connection', socket => {
  console.log('User connected')

  socket.on('create-game', async data => {
    const { token } = JSON.parse(data)
    if (!token) {
      return
    }
    const decoded = jsonwebtoken.verify(token, secretKey)
    if (decoded) {
      const user = await prisma.user.findFirst({
        where: {
          id: decoded.id
        }
      })
      if (!user) {
        return
      }
      socket.userId = user.id
      const gameId = await redisClient.hGet('users', user.id)
      if (gameId) {
        console.log('User ', user, ' in game:', gameId)
        socket.join(gameId)
        const gameState = JSON.parse(await redisClient.hGet('games', gameId))
        socket.emit('game-start', JSON.stringify(gameState))
        return
      }
      if (user) {
        user.password = undefined
        console.log('User created game', user)
        if (matchQueue.length > 0 && matchQueue[0].userId !== socket.userId) {
          const opponent = matchQueue.pop()
          const gameId = Math.random().toString(36).substring(10)
          console.log('Game ID:', gameId)
          socket.join(gameId)
          opponent.join(gameId)
          const gameState = generateNewGameState(
            gameId,
            socket.userId,
            opponent.userId
          )
          redisClient.hSet('games', gameId, JSON.stringify(gameState))
          redisClient.hSet('users', user.id, gameId)
          redisClient.hSet('users', opponent.userId, gameId)
          io.to(gameId).emit('game-start', JSON.stringify(gameState))
          console.log(io.sockets.adapter.rooms)
          publisher.publish('game-start', JSON.stringify({ gameId, gameState }))
        } else {
          if (!matchQueue.includes(socket)) {
            matchQueue.push(socket)
            // console.log('Match queue:', matchQueue)
            socket.emit('create-game-response', 'Waiting for opponent')
          }
        }
      } else {
        console.log('User not found in DB')
      }
    }
  })

  socket.on('move', async data => {
    const { move } = JSON.parse(data)
    const userId = socket.userId
    if (!userId) {
      console.log('User not found')
      return
    }
    const gameId = await redisClient.hGet('users', userId)
    if (!gameId) {
      console.log('Game not found')
      return
    }
    console.log('Move:', move)
    console.log('Game State:', await redisClient.hGet('games', gameId))
    var game = JSON.parse(await redisClient.hGet('games', gameId))
    if (!game) {
      console.log('Game not found')
      return
    }
    if (game.status === 'Completed') {
      return socket.emit('invalid-move', 'Game already completed')
    }
    if (game.whiteUser !== userId && game.blackUser !== userId) {
      console.log('User not in game')
      console.log(game)
      console.log(
        'White:',
        game.whiteUser,
        'Black:',
        game.blackUser,
        'User:',
        userId
      )
      return
    }
    if (move === 'resign') {
      const newGameState = {
        ...game,
        boardState: game.boardState,
        status: 'Completed',
        winnerId: game.whiteUser === userId ? game.blackUser : game.whiteUser,
        result: 'Resignation'
      }
      publisher.publish('game-update', JSON.stringify({ gameId, newGameState }))
      redisClient.hDel('games', gameId)
      redisClient.hDel('users', game.whiteUser)
      redisClient.hDel('users', game.blackUser)
      io.to(gameId).emit('game-update', JSON.stringify(newGameState))
      return
    }
    const userColor = game.whiteUser === userId ? 'w' : 'b'
    if (userColor !== game.boardState.split(' ')[1]) {
      console.log(
        'User color:',
        userColor,
        'Board color:',
        game.boardState.split(' ')[1]
      )
      return socket.emit('invalid-move', 'Not your turn')
    }

    const chessGame = new chess.Chess()
    chessGame.load(game.boardState)
    console.log('Game:', chessGame.fen())
    try {
      chessGame.move(move)
      console.log('Move:', chessGame.history())
    } catch (e) {
      console.log('Invalid move:', e)
      return socket.emit('invalid-move', 'Invalid move')
    }
    if (chessGame.isCheckmate()) {
      console.log('Checkmate')
      const winner = chessGame.turn() === 'w' ? game.blackUser : game.whiteUser
      game = {
        ...game,
        status: 'Completed',
        winnerId: winner,
        result: 'Checkmate'
      }
    }
    if (chessGame.isStalemate()) {
      console.log('Stalemate')
      game = {
        ...game,
        status: 'Completed',
        result: 'Stalemate'
      }
    }
    if (chessGame.isDraw()) {
      console.log('Draw')
      game = {
        ...game,
        status: 'Completed',
        result: 'Draw'
      }
    }
    console.log('Game:', chessGame.ascii())
    const newGameState = {
      ...game,
      boardState: chessGame.fen(),
      moves: [...game.moves, chessGame.history()[0]]
    }
    delete chessGame
    publisher.publish('game-update', JSON.stringify({ gameId, newGameState }))
    if (newGameState.status !== 'Completed') {
      redisClient.hSet('games', gameId, JSON.stringify(newGameState))
    }
    if (newGameState.status === 'Completed') {
      redisClient.hDel('users', game.whiteUser)
      redisClient.hDel('users', game.blackUser)
    }
    io.to(gameId).emit('game-update', JSON.stringify(newGameState))
  })
})

publisher.connect()
subscriber.connect()
redisClient.connect()

app.listen(3000, () => {
  console.log('Server is running on http://localhost:3000')
})

server.listen(4000, () => {
  console.log('Socket server is running on http://localhost:4000')
})

subscriber.subscribe('game-update', async function (message, channel) {
  const { gameId, newGameState } = JSON.parse(message)
  const game = await prisma.game.update({
    where: {
      id: gameId
    },
    data: {
      boardState: newGameState.boardState,
      moves: newGameState.moves,
      status: newGameState.status,
      winnerId: newGameState.winner || null,
      result: newGameState.result || null
    }
  })
})

subscriber.subscribe('game-start', async function (message, channel) {
  const { gameId, gameState } = JSON.parse(message)
  console.log('Game start', gameState)
  console.log(message)
  const game = await prisma.game.create({
    data: {
      id: gameId,
      whiteUserId: gameState.whiteUser,
      blackUserId: gameState.blackUser,
      boardState: gameState.boardState,
      moves: gameState.moves,
      status: 'In Progress'
    }
  })
})
