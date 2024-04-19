/*
  Warnings:

  - Added the required column `boardState` to the `Game` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Game" ADD COLUMN     "boardState" TEXT NOT NULL,
ADD COLUMN     "result" TEXT;
