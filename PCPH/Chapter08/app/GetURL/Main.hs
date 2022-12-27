module Main (main) where

import qualified Data.ByteString as B
import GetURLWreq ( getURL )
import Async ( async, wait, waitAny )
import TimeIt ( timeit )
import Text.Printf ( printf )
import Control.Monad ( replicateM_, forM_ )
import Control.Concurrent ( newEmptyMVar, putMVar, takeMVar, forkIO )


main :: IO ()
main = do
    asyncAndWait
    timedDownloads
    printFirst
    printFirstWithWaitAny

-- Async and wait example
asyncAndWait :: IO ()
asyncAndWait = do
    a1 <- async $ getURL "https://www.wikipedia.org/wiki/Shovel"
    a2 <- async $ getURL "https://www.wikipedia.org/wiki/Spade"
    r1 <- wait a1
    r2 <- wait a2
    print (B.length r1, B.length r2)

-- Timed downloads
timedDownloads :: IO ()
timedDownloads = do
    as <- mapM (async . timeDownload) sites
    mapM_ wait as


sites :: [String]
sites =
    [ "http://www.google.com"
    , "http://www.bing.com"
    , "http://www.yahoo.com"
    , "http://www.wikipedia.com/wiki/Spade"
    , "http://www.wikipedia.com/wiki/Shovel"]

timeDownload :: String -> IO ()
timeDownload url = do
    (page, time) <- timeit $ getURL url
    printf "download: %s (%d bytes, %.2fs)\n" url (B.length page) time

-- Print the first
printFirst :: IO ()
printFirst = do
    m <- newEmptyMVar
    let
        download url = do
            r <- getURL url
            putMVar m (url, r)

    mapM_  (forkIO . download) sites

    (url, r) <- takeMVar m
    printf "%s was first (%d bytes)\n" url (B.length r)

    replicateM_ (length sites - 1) $ do
        (url', r') <- takeMVar m
        printf "%s was downloaded (%d bytes)\n" url' (B.length r')

-- Print the first, using the waitAny function
printFirstWithWaitAny :: IO ()
printFirstWithWaitAny = do
    let
        download url = do
            r <- getURL url
            return (url, r)
    as <- mapM (async . download) sites
    (url, r) <- waitAny as
    printf "%s was first (%d bytes)\n" url (B.length r)
    forM_ as $ \a -> do
        (url', r') <- wait a
        printf "%s was downloaded (%d bytes)\n" url' (B.length r')