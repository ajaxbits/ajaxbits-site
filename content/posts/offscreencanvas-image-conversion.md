+++
title = 'Easy Client-Side Image Conversion with Browser APIs'
date = 2024-02-24T16:06:20-06:00
draft = true
+++

# Easy Client-Side Image Conversion with Browser APIs

Image conversion on the web is an incredibly common task. There are thousands of methods and [hundreds](https://www.npmjs.com/search?q=image+manipulation) of libraries available that get it done.

But what if you just can't be bothered with all that?

What if you're banging out a prototype, an MVP, or simply want to get something working quickly? What if you don't want to add _another_ dependency to your project just to do basic image conversion?

Well, you're in luck! Here's a quick, portable recipe to easily transcode an image using native browser APIs and vanilla JavaScript.

## Problem

Suppose our web app does image conversion from PNG to JPEG. We have a form for users to submit PNG files that looks something like this:

```html
<form id="converter" action="#" method="post" enctype="multipart/form-data">
    <label for="image">Select PNG to convert</label>
    <input id="image" name="image" type="file" accept="image/png" />
    <input type="submit" value="Convert!" />
</form>
```

We'd rather not have to deal with additional dependencies, wait for responses from our server, or shell out to operating system processes for our simple use case.

Is there an easy, native way to transcode a user-supplied image from PNG to JPEG? Can we do this on the client?

## Solution

The `OffscreenCanvas` [browser API](https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas) provides an efficient, client-side solution for image conversion. Here's how we can use it.

Our form uses `multipart/form-data` encoding, meaning we'll receive user-submitted PNGs as raw bytes. So, let’s start by creating a function that will convert a PNG `Blob` to a JPEG `Blob`.

First, we wrap incoming PNG `Blob` data in an `Image` object for convenience. Then, we draw that `Image` onto a new offscreen `<canvas>`, created with the `OffscreenCanvas` browser API:

```js
async function convertImage(pngBlob) {
  const img == new Image();
  img.src = URL.createObjectURL(pngBlob);
  await img.decode();

  const canvas = new OffscreenCanvas(img.width, img.height);
  canvas.getContext("2d").drawImage(img, 0, 0);
  
  // ...
}
```

This is the key element that makes our solution practical and portable.

The `OffscreenCanvas` API is included in [all major modern browsers](https://caniuse.com/offscreencanvas) and contains [many useful features](https://bucephalus.org/text/CanvasHandbook/CanvasHandbook.html) for image manipulation.[^1]

For instance, it has a wonderful `convertToBlob` [method](https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas/convertToBlob) that returns a `Promise` containing the canvas's image in `Blob` format. We can also specify the encoding of the returned `Blob`, which is extremely handy.

Knowing this, we'll use `convertToBlob` to losslessly transform our canvas into a JPEG `Blob`, returning the resulting `Promise`.

```js
async function convertImage(pngBlob) {
  const img = new Image();
  img.src = URL.createObjectURL(pngBlob);
  await img.decode();

  const canvas = new OffscreenCanvas(img.width, img.height);
  canvas.getContext("2d").drawImage(img, 0, 0);

  return canvas.convertToBlob({ type: "image/jpeg", quality: 1.0 });
}
```

Now that the heavy lifting of conversion is over, we can throw together a simple function that, again, uses native browser APIs to automatically download a given `Blob` on the client.

```js
function triggerDownload(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(a);
}
```

Finally, we'll bring it all together by hooking up a form submission listener that grabs submitted PNG bytes, converts them to JPEG bytes, and downloads the JPEG as a new file.

```js
async function handleSubmit(e) {
  e.preventDefault();

  const form = e.currentTarget;
  const data = new FormData(form);

  const png = data.get("image");
  const filename = png.name.split(".").slice(0, -1).join(".") || png.name;

  const jpg = await convertImage(png);
  triggerDownload(jpg, `${filename}.jpg`);
}

document.querySelector("#converter").addEventListener("submit", handleSubmit);
```

And there we have it!

## Discussion

Using the `OffscreenCanvas` API for image transcoding on the client offers several advantages, including portability, responsiveness, and extensibility:

- Since this technique allows us to convert images solely using native browser APIs and vanilla JavaScript, this recipe can be re-used with any frontend framework we happen to be working with.
- Doing the transcode on the client also keeps the user experience snappy, since we're not waiting on the network.
- Finally, using `OffscreenCanvas` unlocks all the different image manipulation functions available for `<canvas>` elements. We can easily extend this solution if we want to include additional image manipulation features in our app in the future.

However, there are tradeoffs to consider. One of the biggest is image codec compatibility. While all modern browsers support the `convertToBlob` method with `image/jpeg` and `image/png` encodings, not every codec is supported.[^2] Notably, `image/webp` is [not yet available](https://caniuse.com/mdn-api_offscreencanvas_converttoblob_option_type_parameter_webp) in Safari. And of course, the `OffscreenCanvas` browser API is not available _at all_ for Node.js. Therefore, if you need additional codecs or Node support, the `sharp` [module](https://www.npmjs.com/package/sharp) might be the way to go.

Even with these tradeoffs in mind, `OffscreenCanvas` remains an effective solution for many use cases.

Whenever I'm putting together a quick project and I need something to "just work," this is a great trick to have up my sleeve!


---

[^1]: `OffscreenCanvas` is also great because it is decoupled from the DOM and can be run in a [web worker](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) context, allowing you to run image manipulation operations on another thread.

[^2]: Sorry, [JPEG-XL](https://en.wikipedia.org/wiki/JPEG_XL) fans :cry: