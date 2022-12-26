module Main (main) where

import Control.Monad.Fix ( fix )
import Control.Concurrent ( threadDelay, forkIO )
import Text.Printf ( printf )

main :: IO ()
main = fix $ \loop -> do
    s <- getLine
    if s == "exit"
        then return ()
        else forkIO (setReminder s) >> loop

setReminder :: String -> IO ()
setReminder s = do
    let t = read s :: Int
    printf "Ok, I'll remind you in %d seconds\n" t
    threadDelay (10 ^ (6 :: Int) * t)
    printf "%d seconds is up! BING!\BEL\n" t
