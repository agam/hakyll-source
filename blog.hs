{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Applicative ((<$>))
import Data.Monoid (mappend, mconcat)

import Hakyll

main :: IO()
main = hakyll $ do
    match "img/*" $ do
        route    idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route    idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route    idRoute
        compile compressCssCompiler

    match "templates/*" $ compile templateCompiler

    --- About page
    --- TODO(agam): Add separate template for the about page
    match "about.markdown" $ do
        route     $ setExtension "html"
        compile   $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    --- Individual posts
    --- TODO(agam): Add tags for posts, and a page with tags for all posts
    match "posts/*" $ do
        route     $ setExtension "html"
        compile   $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" postContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    --- List of all posts
    --- TODO(agam): Find a way to avoid duplication; this is basically right
    ---             now the same as the Main page, without the 'take 3'
    create ["posts.html"] $ do
    route idRoute
    compile $ do
        list <- postList "posts/*" recentFirst id
        let postsContext = constField "posts" list `mappend`
                constField "title" "Posts" `mappend`
                defaultContext
        
        makeItem ""
            >>= loadAndApplyTemplate "templates/posts.html" postsContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    --- Main page
    create ["index.html"] $ do
    route idRoute
    compile $ do
        list <- postList "posts/*" recentFirst (take 3)
        let indexContext = constField "posts" list `mappend`
                constField "title" "Home" `mappend`
                defaultContext
        
        makeItem ""
            >>= loadAndApplyTemplate "templates/index.html" indexContext
            >>= loadAndApplyTemplate "templates/default.html" indexContext
            >>= relativizeUrls



--- Contexts etc

postContext :: Context String
postContext = mconcat
    [ dateField "date" "%B %e, %Y"
    , defaultContext
    ]

postList :: Pattern -> ([Item String] -> Compiler [Item String]) -> ([Item String] -> [Item String]) -> Compiler String
postList pattern prep listmodifier = do
    posts <- prep =<< loadAll pattern
    itemTemplate <- loadBody "templates/postitem.html"
    applyTemplateList itemTemplate postContext (listmodifier posts)


