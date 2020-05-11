import React from 'react';
import withObservables from "@nozbe/with-observables";

const PostRow = ({ post, onEdit, onDelete }) => (
    <tr key={post._raw.id}>
        <td>{post.title}</td>
        <td>{post.content}</td>
        <td>{post.likes}</td>
        <td>{post.createdAt.toString()}</td>
        <td>{post.updatedAt.toString()}</td>
        <td>
            <button onClick={(e) => {onEdit(post)}}>Edit</button>
            <button onClick={(e) => {onDelete(post)}}>Delete</button>
        </td>
    </tr>
)

export default withObservables(["post"], ({ post }) => ({
    post: post.observe()
}))(PostRow)