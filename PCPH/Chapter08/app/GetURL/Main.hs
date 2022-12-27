module Main (main) where

import qualified Data.ByteString as B
import GetURLWreq ( getURL )
import Async ( async, wait )
import TimeIt ( timeit )
import Text.Printf ( printf )

main :: IO ()
main = do
    asyncAndWait
    timedDownloads

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
