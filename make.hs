#!/usr/bin/env runhaskell
module Main where

import System.Process (readProcess)
import System.FilePath.Posix (takeBaseName, takeExtension, (</>))
import System.Directory (getDirectoryContents)
import Control.Monad.IO.Class (liftIO)
import Development.Shake (shake, ShakeOptions(..), shakeOptions, (*>), system', want, need, Action, writeFile', Verbosity(Loud))

toHtml :: FilePath -> FilePath -> Action String
toHtml from to = liftIO $ readProcess "rst2html"
  [ "--no-generator"
  , "--no-datestamp"
  , "--no-source-link"
  , "--strip-comments"
  , "--link-stylesheet"
  , "--footnote-references=superscript"
  , "--table-style=defaulttable"
  , "--stylesheet-path=html/css/html4css1.css,html/css/main.css"
  , from
  , to
  ] ""

srcOf :: FilePath -> FilePath
htmlOf :: FilePath -> FilePath

srcOf  f = "src"  </> (takeBaseName f ++ ".rst" )
htmlOf f = "html" </> (takeBaseName f ++ ".html")

main :: IO ()
main = do
  srcs <- liftIO $ getDirectoryContents "src"
  let dests = map htmlOf $ filter ((==".rst") . takeExtension) $ srcs

  shake shakeOptions{shakeFiles=".", shakeVerbosity=Loud, shakeThreads=4} $ do
    ("html" </> "*.html") *> \f -> do
      let src = srcOf f
      need [src]
      toHtml src f
      return ()
    want dests