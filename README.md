<div align="center">

<h1>Arturo Docker Images</h1>

### Official Docker images for the Arturo programming language

![License](https://img.shields.io/github/license/arturo-lang/docker?style=for-the-badge) [![Docker Pulls](https://img.shields.io/docker/pulls/arturolang/arturo?style=for-the-badge)](https://hub.docker.com/r/arturolang/arturo)

</div>

---

<!--ts-->
   * [Quick Start](#quick-start)
   * [Available Tags](#available-tags)
   * [Usage Examples](#usage-examples)
      * [Interactive REPL](#interactive-repl)
      * [Run a Local Script](#run-a-local-script)
      * [Run Inline Code](#run-inline-code)
      * [Use Full Variant](#use-full-variant)
      * [Use Nightly Builds](#use-nightly-builds)
   * [Contributing](#contributing)
      * [Build Images](#build-images) 
   * [License](#license)
<!--te-->

---

## Quick Start
```bash
# Run REPL
docker run -it arturolang/arturo

# Run a script
docker run -v $(pwd):/workspace arturolang/arturo script.art

# Run inline code
docker run arturolang/arturo -e "print 'Hello, World!'"
```

## Available Tags

| Tag | Description |
|-----|-------------|
| `latest`, `mini` | Mini build (default) |
| `full` | Full build with high-precision math & GUI dependencies |
| `nightly` | Nightly mini build |
| `nightly-full` | Nightly full build |

> [!NOTE]
> Not sure which variant to use? See the [Build Variants documentation](https://arturo-lang.io/documentation/getting-started/#build-variants) for details on mini vs full. Hint: most likely you want need anything other than the default/mini build 😉

> [!CAUTION]
> **Tag naming clarification:** In Arturo's context, "latest" typically refers to nightly builds. However, following Docker Hub conventions, the `:latest` tag here points to the **stable mini** variant (our recommended default). For nightly builds, use the `:nightly` or `:nightly-full` tags explicitly.

## Usage Examples

### Interactive REPL
```bash
docker run -it arturolang/arturo
```

### Run a Local Script
```bash
docker run -v $(pwd):/workspace arturolang/arturo script.art
```

### Run Inline Code
```bash
docker run arturolang/arturo -e "print 'Hello from Docker!'"
```

### Use Full Variant
```bash
docker run -it arturolang/arturo:full
```

### Use Nightly Builds
```bash
# Mini nightly
docker run -it arturolang/arturo:nightly

# Full nightly
docker run -it arturolang/arturo:nightly-full
```

## Runtime images

All four variants use a `scratch` runtime containing Arturo, its runtime
libraries, certificates and required data, with no shell or package manager.
Separate Ubuntu 24.04 stages download Arturo and install its dependencies. Mini
copies the loader and selected libraries rather than an entire distribution.
Full also retains GMP, MPFR and WebKit, including WebKit's transitive GTK
dependencies, runtime data and sandbox helper processes.

Use the Arturo entrypoint directly: shell commands such as `sh` and `bash`, and
Arturo operations that launch external system commands, require a separate image
with those programs installed. GUI use still requires a display and appropriate
container configuration. CI validates CLI execution and full-variant WebKit loading on a virtual X11
display. Interactive desktop integration still requires host setup.

GitHub Actions builds and smoke-tests every Dockerfile on Linux amd64 for pull
requests and pushes to `master`. Builds are not published by validation. Other
architectures are not covered by this workflow. Image sizes depend on upstream
artifacts and runtime dependencies and are not fixed estimates.

## Contributing

Want to build and test the images locally? That's actually quite straightforward! :)

### Build Images

```bash
# Mini (stable)
docker build -f Dockerfile-stable.mini -t arturo:mini .

# Full (stable)
docker build -f Dockerfile-stable -t arturo:full .

# Mini (nightly)
docker build -f Dockerfile-latest.mini -t arturo:nightly .

# Full (nightly)
docker build -f Dockerfile-latest -t arturo:nightly-full .
```

---

## License

MIT License

Copyright (c) 2019-2026 Yanis Zafirópulos (aka Dr.Kameleon)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
