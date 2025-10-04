import app from './api/server'

const port = Number(process.env.PORT || 3000)

app.listen(port, () => console.log(`Server listening on ${port}`))
