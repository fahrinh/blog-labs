import React from 'react';
import withObservables from "@nozbe/with-observables";
import { withDatabase } from '@nozbe/watermelondb/DatabaseProvider'
import PostRow from './PostRow'

const PostList = ({ posts, onEdit, onDelete }) => (
    <table>
        <thead>
            <tr>
                <th>Title</th>
                <th>Content</th>
                <th>Likes</th>
                <th>Created At</th>
                <th>Updated At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            {posts.map(post => <PostRow key={post._raw.id} post={post} onEdit={onEdit} onDelete={onDelete} />)}
        </tbody>
    </table>
)

export default withDatabase(withObservables([], ({ database }) => ({
    posts: database.collections.get('posts').query().observe(),
}))(PostList))