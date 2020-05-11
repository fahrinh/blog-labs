import React from 'react';
import { render } from 'react-dom';
import { Database } from '@nozbe/watermelondb'
import LokiJSAdapter from '@nozbe/watermelondb/adapters/lokijs'
import DatabaseProvider from '@nozbe/watermelondb/DatabaseProvider'

import schema from './model/schema'
import Post from './model/Post'

import App from './App'

const adapter = new LokiJSAdapter({
  schema,
  useWebWorker: false,
  useIncrementalIndexedDB: true,
  onIndexedDBVersionChange: () => {
    if (checkIfUserIsLoggedIn()) {
      window.location.reload()
    }
  },
})

const database = new Database({
  adapter,
  modelClasses: [
    Post,
  ],
  actionsEnabled: true,
})

const rootElement = document.getElementById('blog-app');

render(
  <DatabaseProvider database={database}>
    <App />
  </DatabaseProvider>,
  rootElement);