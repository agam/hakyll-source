{-# LANGUAGE OverloadedStrings #-}

import Control.Arrow ((>>>))

import Hakyll

main :: IO()
main = hakyll $ do
    match "images/*" $ do
        route    idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route    idRoute
        compile compressCssCompiler

    match "templates/*" $ compile templateCompiler

    match (list ["about.markdown", "index.markdown"]) $ do
        route     $ setExtension "html"
        compile   $ pageCompiler
	    >>> applyTemplateCompiler "templates/default.html"
            >>> relativizeUrlsCompiler

    match "posts/*" $ do
        route     $ setExtension "html"
        compile   $ pageCompiler
            >>> applyTemplateCompiler "templates/post.html"
            >>> relativizeUrlsCompiler
