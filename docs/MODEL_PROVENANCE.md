# Downloadable model provenance

**Reviewed:** 10 November 2026  
**Scope:** English Whisper ONNX models and Silero VAD model downloaded by the app

The app now downloads from immutable Hugging Face revisions and verifies every selected file against a SHA-256 value compiled into the app. A mismatch stops the installation. The tree request supplies actual file sizes for progress, but each is checked against a fixed per-file ceiling and the byte stream is stopped if it exceeds either declared size or that ceiling. The app does not trust the returned revision or checksum as the expected value.

## Whisper models

These repositories identify the files as ONNX exports of OpenAI Whisper and are listed by the sherpa-onnx project. The pinned revisions below were read from the repository commit pages on the review date.

| App choice | Repository revision | File | Expected SHA-256 |
|---|---|---|---|
| tiny.en | [`d026532c022fa99fd789d6b32446a1df7b6bfc43`](https://huggingface.co/csukuangfj/sherpa-onnx-whisper-tiny.en/commit/d026532c022fa99fd789d6b32446a1df7b6bfc43) | `tiny.en-encoder.int8.onnx` | `0ce578b827c94a961aacb8fa14b02f096504b337e5c94be37c36238cbe3e8bc6` |
|  |  | `tiny.en-decoder.int8.onnx` | `06c0e6ff6348d427e51839219d1c886c18cfdf411e629e33f5e1679bff9c1527` |
|  |  | `tiny.en-tokens.txt` | `306cd27f03c1a714eca7108e03d66b7dc042abe8c258b44c199a7ed9838dd930` |
| base.en | [`59eea950fc76df2453efb57e6c0fd334548e8ffe`](https://huggingface.co/csukuangfj/sherpa-onnx-whisper-base.en/commit/59eea950fc76df2453efb57e6c0fd334548e8ffe) | `base.en-encoder.int8.onnx` | `ef6b936f4c9b1d90a3b68634b60c4ed8576b26172b33c2535ec0e933c9edb823` |
|  |  | `base.en-decoder.int8.onnx` | `f7162ad6db2dbef16cfaeaa7f945b9d7dd9c1b8d472f6aca82f2273d185e4d41` |
|  |  | `base.en-tokens.txt` | `306cd27f03c1a714eca7108e03d66b7dc042abe8c258b44c199a7ed9838dd930` |
| small.en | [`d9533f69affd85061aee349af7fea5cb2996dbbe`](https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small.en/commit/d9533f69affd85061aee349af7fea5cb2996dbbe) | `small.en-encoder.int8.onnx` | `8bdac288f369aa94ee2194059238c465ed82ea9d47ee8fa4a8c0a891873e462f` |
|  |  | `small.en-decoder.int8.onnx` | `710ccf890e10f3faa15f51ec346081a2723c9f3adb6e4da81c6573a5a6f877fb` |
|  |  | `small.en-tokens.txt` | `306cd27f03c1a714eca7108e03d66b7dc042abe8c258b44c199a7ed9838dd930` |

The token vocabulary is shared by the selected English models. Its Git blob ID and resolved SHA-256 are pinned in `model_download_manager.dart`.

## Voice activity detection

| Model | Repository revision | File | Expected SHA-256 |
|---|---|---|---|
| Silero VAD | [`66b1409e6c67c060fd1abe9f01e580d1a9c2de9f`](https://huggingface.co/csukuangfj/vad/commit/66b1409e6c67c060fd1abe9f01e580d1a9c2de9f) | `silero_vad.onnx` | `a35ebf52fd3ce5f1469b2a36158dba761bc47b973ea3382b3186ca15b1f5af28` |

## License and attribution review

- OpenAI states that Whisper code and model weights are released under MIT; include the OpenAI copyright/license notice if distributing those model weights or substantial derived material. [Whisper README](https://github.com/openai/whisper#license), [MIT license](https://github.com/openai/whisper/blob/main/LICENSE)
- Silero VAD is published under MIT. Include the Silero copyright/license notice in third-party notices if distributing or bundling the model. [Silero VAD repository](https://github.com/snakers4/silero-vad)
- The sherpa-onnx project documents ONNX exports of Whisper and hosts the selected model repositories. [Whisper ONNX export documentation](https://github.com/k2-fsa/sherpa/blob/master/docs/source/onnx/pretrained_models/whisper/export-onnx.rst)
- The selected converted Whisper repositories currently have no model card that independently states a license or full conversion provenance. The upstream MIT statement is useful evidence, but the publisher must still review the exact converted files, attribution obligations, and included runtime dependency notices before global release. This document does not assert that all redistribution rights have been cleared.

## Update procedure

1. Review the model repository, immutable commit, file list, source/provenance, and applicable licenses.
2. Record each selected file's byte length and SHA-256 from a trusted source; verify downloaded bytes independently before changing the app constants.
3. Update the constants and this document together. Do not restore runtime resolution of a mutable branch or runtime-provided checksum as the expected checksum.
4. Run the real transcription acceptance set on Android and iOS, compare transcript quality and performance, and record the tested app/model revisions.
5. Rebuild and review the release artifact, Data safety/App Privacy disclosure, model notices, and listing statements.
