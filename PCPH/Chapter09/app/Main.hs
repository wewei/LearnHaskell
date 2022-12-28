module Main (main) where

import Data.Maybe ( listToMaybe )
import System.Environment ( getArgs )
import qualified Cmdlet.Cancellable as Cancellable
import qualified Cmdlet.Timeout as Timeout

main :: IO ()
main = do
    args <- getArgs
    case listToMaybe args of 
        Just "cancellable" -> Cancellable.run
        Just "timeout"     -> Timeout.run
        _                  -> putStrLn
            "Available commands are \"cancelable\", \"timeout\"."

