import { synchronize } from '@nozbe/watermelondb/sync'

export default async function syncData(database) {
    let latestVersionOfSession = 0
    let changesOfSession = {}

    await synchronize({
        database,
        pullChanges: async ({ lastPulledAt }) => {
            const response = await fetch(`http://localhost:4000/api/sync/pull?lastPulledVersion=${lastPulledAt || 0}`)
            if (!response.ok) {
                throw new Error(await response.text())
            }

            const { changes, latestVersion } = await response.json()
            latestVersionOfSession = latestVersion
            changesOfSession = changes

            return { changes, timestamp: latestVersion }
        },
        pushChanges: async ({ changes, lastPulledAt }) => {
            const response = await fetch(`http://localhost:4000/api/sync/push?lastPulledVersion=${lastPulledAt || 0}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(changes)
            })
            if (!response.ok) {
                throw new Error(await response.text())
            }
            const { changes: changesFromPush, latestVersion } = await response.json()
            latestVersionOfSession = latestVersion
            changesOfSession = changesFromPush
        },
    })

    await synchronize({
        database,
        pullChanges: async ({ lastPulledAt }) => {
            return { changes: changesOfSession, timestamp: latestVersionOfSession }
        },
        pushChanges: async ({ changes, lastPulledAt }) => {
            throw new Error(await response.text())
        },
    })
}