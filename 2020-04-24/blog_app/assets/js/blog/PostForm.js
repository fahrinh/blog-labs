import React, { useState, useEffect } from 'react';

export default function PostForm({ post, clearPost, createPost, updatePost, syncData }) {
    const [title, setTitle] = useState(post ? post.title : "")
    const [content, setContent] = useState(post ? post.content : "")
    const [likes, setLikes] = useState(post ? post.likes : "")

    useEffect(() => {
        setTitle(post ? post.title : "")
        setContent(post ? post.content : "")
        setLikes(post ? post.likes : "")
    }, [post])

    const onReset = (e) => {
        e.preventDefault()
        clearForm()
    }

    const onSync = (e) => {
        e.preventDefault()
        syncData()
    }

    const onSubmit = async (e) => {
        e.preventDefault()

        const inputtedForm = { title, content, likes: parseInt(likes) }

        if (post) {
            await updatePost(post, inputtedForm)
        } else {
            await createPost(inputtedForm)
            clearForm()
        }
    }

    const clearForm = () => {
        setTitle("")
        setContent("")
        setLikes("")
        clearPost()
    }

    return (
        <form>
            <label>
                Title:
                <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} />
            </label>
            <label>
                Content:
                <input type="text" value={content} onChange={(e) => setContent(e.target.value)} />
            </label>
            <label>
                Likes:
                <input type="number" value={likes} onChange={(e) => setLikes(e.target.value)} />
            </label>
            <button className="button button-outline" onClick={onReset}>Add New / Reset</button>
            <button onClick={onSubmit}>Save</button>
            <button className="button button-clear" onClick={onSync}>Sync</button>
        </form>
    )
}