module Chan
    ( Chan
    , newChan
    , readChan
    , writeChan
    , dupChan
    , unGetChan
    ) where

import Control.Concurrent ( MVar, newEmptyMVar, newMVar, putMVar, takeMVar, readMVar )

data Chan a = Chan (MVar (Stream a)) (MVar (Stream a))

type Stream a = MVar (Item a)
data Item a   = Item a (Stream a)

newChan :: IO (Chan a)
newChan = do
    hole <- newEmptyMVar
    rp   <- newMVar hole
    wp   <- newMVar hole
    return $ Chan rp wp

readChan :: Chan a -> IO a
readChan (Chan rp _) = do
    stream <- takeMVar rp
    Item val rest <- readMVar stream
    putMVar rp rest
    return val

writeChan :: Chan a -> a -> IO ()
writeChan (Chan _ wp) val = do
    newHole <- newEmptyMVar
    oldHole <- takeMVar wp
    putMVar oldHole (Item val newHole)
    putMVar wp newHole

dupChan :: Chan a -> IO (Chan a)
dupChan (Chan _ wp) = do
    hole <- readMVar wp
    newRp <- newMVar hole
    return $ Chan newRp wp

unGetChan :: Chan a -> a -> IO ()
unGetChan (Chan rp _) val = do
    newRp <- newEmptyMVar
    readEnd <- takeMVar rp
    putMVar newRp (Item val readEnd)
    putMVar rp newRp
