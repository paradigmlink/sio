# WASM example

Examples use a CLI tool named `wasm-pack` to build this example:

```
cargo install wasm-pack
```

(wasm-pack should be available if you used `nix-shell` in the root directory)

## Building

To build the example, run:

```
wasm-pack build --target web
```

## Running

To run the example, start a webserver server the local folder:
(simple-http-server is available via `nix-shell` in the root directory)


```
simple-http-server
```

Then, open a browser at https://0.0.0.0:8000 and watch the ticker print entries to the window.
