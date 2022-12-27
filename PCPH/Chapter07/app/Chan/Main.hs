module Main (main) where

import Control.Monad ( forever )
import Control.Concurrent ( forkIO, threadDelay )
import Text.Printf ( printf )
import Chan ( Chan, newChan, readChan, writeChan, dupChan )
-- import Control.Concurrent ( Chan, newChan, readChan, writeChan, dupChan )

main :: IO ()
main = do
    chan <- newChan
    sequence_ $ do
        i <- [1..3] :: [Int]
        return $ do
            ch <- dupChan chan
            forkIO $ runner ("#" <> show i) ch
    _ <- forkIO $ runner "#sink" chan
    sequence_ $ do
        i <- [1..5] ::  [Int]
        return $ do
            writeChan chan $ "Tick " <> show i
            threadDelay $ 10 ^ (6::Int)
            

runner :: String -> Chan String -> IO ()
runner name ch = do
    printf "Thread %s started\n" name
    forever $ do
        msg <- readChan ch
        printf "Thread %s: %s\n" name msg
