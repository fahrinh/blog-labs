import React, { useState } from 'react';
import { useDatabase } from '@nozbe/watermelondb/hooks'
import { v4 as uuidv4 } from 'uuid';

import syncData from './sync'
import PostList from './PostList'
import PostForm from './PostForm'

export default function App() {
    const database = useDatabase()
    const [post, setPost] = useState()
    const postsCollection = database.collections.get("posts");

    function clearPost() {
        setPost(undefined)
    }

    function onEdit(selectedPost) {
        setPost(selectedPost)
    }

    async function onDelete(selectedPost) {
        await database.action(async () => {
            await selectedPost.markAsDeleted()
        })
    }

    async function createPost(inputtedForm) {
        await database.action(async () => {
            const newPost = await postsCollection.create(post => {
                post._raw.id = uuidv4()
                post.title = inputtedForm.title
                post.content = inputtedForm.content
                post.likes = inputtedForm.likes
            });
        })
    }

    async function updatePost(currentPost, inputtedForm) {
        await database.action(async () => {
            await currentPost.update(post => {
                post.title = inputtedForm.title
                post.content = inputtedForm.content
                post.likes = inputtedForm.likes
            });
        })
    }

    return (
        <div>
            <PostForm post={post} clearPost={clearPost} createPost={createPost} updatePost={updatePost} syncData={() => syncData(database)} />
            <PostList onEdit={onEdit} onDelete={onDelete} />
        </div>
    )
}