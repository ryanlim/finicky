#!/usr/bin/env python3
"""Serves redirect.html for every request, on loopback only.

Usage: server.py [port]   (default 48731)
"""
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

PAGE = (Path(__file__).resolve().parent / "redirect.html").read_bytes()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(PAGE)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Referrer-Policy", "no-referrer")
        self.end_headers()
        self.wfile.write(PAGE)

    do_HEAD = do_GET

    def log_message(self, *args):  # paths carry no URLs, but stay quiet anyway
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 48731
    HTTPServer(("127.0.0.1", port), Handler).serve_forever()
