import axios from 'axios';

const envUrl = process.env.REACT_APP_API_URL;
const envPort = process.env.REACT_APP_API_PORT;

// CSV 出力画面と同じく、API はフロントとは別オリジンで動く
export const apiBaseUrl = `${envUrl}:${envPort}`;

export const api = axios.create({ baseURL: apiBaseUrl });
