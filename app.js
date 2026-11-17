const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.json({ message: 'devops-project API' });
});

// used by Docker, Kubernetes probes and monitoring later
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// app is exported without listen() so tests can use it directly
module.exports = app;