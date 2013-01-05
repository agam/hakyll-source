{-# LANGUAGE OverloadedStrings #-}
module Main where

import Prelude hiding (id)
import Control.Category (id)
import Control.Arrow ((>>>), (***), arr)
import Data.Monoid (mempty, mconcat)

import Hakyll

main :: IO()
main = hakyll $ do
    match "images/*" $ do
        route    idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route    idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route    idRoute
        compile compressCssCompiler

    match "templates/*" $ compile templateCompiler

    match (list ["about.markdown"]) $ do
        route     $ setExtension "html"
        compile   $ pageCompiler
	    >>> applyTemplateCompiler "templates/default.html"
            >>> relativizeUrlsCompiler

    match "index.html" $ route idRoute
    create "index.html" $ constA mempty
        >>> arr (setField "title" "Agam's Mashed-up Pome")
        >>> requireAllA "posts/*" (id *** arr (take 3 . reverse . chronological) >>> addPostList)
        >>> applyTemplateCompiler "templates/index.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler

    match "posts/*" $ do
        route     $ setExtension "html"
        compile   $ pageCompiler
            >>> applyTemplateCompiler "templates/post.html"
	    >>> applyTemplateCompiler "templates/default.html"
            >>> relativizeUrlsCompiler

    match "posts.html" $ route idRoute 
    create "posts.html" $ constA mempty
        >>> arr (setField "title" "All posts")
        >>> requireAllA "posts/*" addPostList
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler


addPostList :: Compiler (Page String, [Page String]) (Page String)
addPostList = setFieldA "posts" $
    arr (reverse . chronological)
        >>> require "templates/postitem.html" (\p t -> map (applyTemplate t) p)
        >>> arr mconcat
        >>> arr pageBody

