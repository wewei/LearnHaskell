module Main (main) where

import Data.Maybe
import System.Environment
import qualified Cmdlet.Cancellable as Cancellable

main :: IO ()
main = do
    args <- getArgs
    case listToMaybe args of 
        Just "cancellable" -> Cancellable.run
        _                  -> putStrLn
            "Available commands are \"cancelable\"."

