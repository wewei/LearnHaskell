module Main (main) where

import Logger ( initLogger, logMessage, logStop )

main :: IO ()
main = do
    l <- initLogger
    logMessage l "Hello"
    logMessage l "Bye"
    logStop l
