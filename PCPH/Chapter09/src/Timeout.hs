{-# LANGUAGE InstanceSigs #-}
module Timeout ( timeout ) where
import Control.Concurrent (myThreadId, forkIO, threadDelay)
import Data.Unique (newUnique, Unique)
import Control.Exception (handleJust, bracket, throwTo, AsyncException(ThreadKilled), Exception)
import Data.Data (Typeable)

newtype Timeout = Timeout Unique deriving (Eq, Typeable)
instance Show Timeout where
    show :: Timeout -> String
    show _ = "<<timeout>>"

instance Exception Timeout

timeout :: Int -> IO a -> IO (Maybe a)
timeout t m
    | t <  0    = fmap Just m
    | t == 0    = return Nothing
    | otherwise = do
        pid <- myThreadId
        u   <- newUnique
        let ex = Timeout u
        handleJust
            (\e -> if e == ex then Just () else Nothing)
            (\_ -> return Nothing)
            (bracket (forkIO $ do threadDelay t
                                  throwTo pid ex)
                     (`throwTo` ThreadKilled)
                     (\_ -> fmap Just m))