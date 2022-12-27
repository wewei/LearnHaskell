module TimeDownload ( timeDownload ) where

import qualified Data.ByteString as B
import Text.Printf ( printf )

import TimeIt ( timeit )
import GetURL ( getURL )

timeDownload :: String -> IO ()
timeDownload url = do
    (r, t) <- timeit . getURL $ url
    printf "downloaded: %s (%d bytes, %.2fs)\n" url (B.length r) t
