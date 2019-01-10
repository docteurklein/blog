# Writing web components

I played a bit with [web components](https://developer.mozilla.org/en-US/docs/Web/Web_Components) recently and wanted to share some tips and tricks about them.  
That's gonna be a random list of thoughts and findings about do's and don't.

> Note: I might be totally wrong on some topics, so don't hesitate to [correct me](https://github.com/docteurklein/blog/edit/master/public/posts/2019/01/writing-web-components.md), that would be awesome.

> You should probably use the f\*\*\*\* platform, Karen. [\*](https://pbs.twimg.com/media/DT_3OvBXkAUYeMM.jpg:large)

## Plan

We're gonna discuss theory, naming, and the reasons why we want web components, and then list all the little tricks I discovered while writing [hippiemedia/web-components](https://github.com/hippiemedia/web-components) to render API reference endpoints like this:

![example](/posts/2019/01/writing-web-components/example.png)


- [What's the difference between Web Components and Custom Elements?](#h-whats-the-difference-between-web-components-and-custom-elements?)
- [Why writing Web Components when we have React](#h-why-writing-web-components-when-we-have-react)
- [How to avoid the `div` soup](#h-how-to-avoid-the-div-soup)
- [How to keep the mouse focus?](#h-how-to-keep-the-mouse-focus)
- [How to manipulate `<slot>` contents?](#h-how-to-manipulate-slot>-contents?)
- [How to deploy your web components?](#h-how-to-deploy-your-web-components)
- [How to style a web component?](#h-how-to-style-a-web-component)

### What's the difference between Web Components and Custom Elements?

Web Components is the general idea of modularization, while Custom Element is one of the 3 main technologies to accomplish it.  
Usually to create a Web Component, you're gonna define a Custom Element (1st technology) and render some content in a shadow DOM (2nd technology).

You can totally define a custom element but decide to not use a shadow DOM and render its content as "normal" children.  
However, a shadow DOM guarantees isolation and thus improves reusability in other, uncontrolled contexts.  
That one of the main requirements of a *good* component.

A second important aspect of a *good* component is a clean interface. That's where the `Custom Element` technology comes in:
You can define a new HTML tag (and name it `h-endpoint` if you want), and the browser would treat them like any other HTML tag (a `div` or a `video` tag).

This Custom Element can then define some attributes, properties and slots that together form a clean interface (API).

The Third technology is `HTML Templates`, but you don't specifically need it compared to the other two.


### Why writing Web Components when we have [React](https://reactjs.org/)?

React is cool and all, and maybe they'll come to using web components internally some day, but right now they seem to focus more on providing functional APIs around state and Higher Order Components (which is amazing).

The React component API also seems to be the main inspiration of some Web Components libraries like [stencil](https://stenciljs.com/) or [polymer/lit-element](https://lit-element.polymer-project.org/), so kudos to react for being a real forward-thinker on those topics.

> Note: I could have used lit-element and/or stencil (and I did test them both), but I like going in depth (NIH syndrom anyone?).

React however doesn't play really nice in heterogeneous or uncontrolled environments where the DOM could be manipulated from the outside.  
If you want React, you can only have React in a controlled sub-tree of the DOM.  
Of course you can `ReactDOM.render(element, document.getElementById('root'))`, but everything that's under the root *has to be* rendered by react.

Even if React would play nice with heterogeneous DOM manipulations, it still pollutes the DOM with **many** non-semantic HTML tags:

```html
<div id="root">
    <div data-reactroot="" class="app">
        <div class="container mt-4">
            <div class="home mt-5">
                <div class="row">
                    <div class="col-12">
                        <h2 class="mb-3">
                            Compare Products</h2>
                    </div>
                </div>
                <div class="row mt-3">
                    <div class="col-sm-6 col-md-3">
                        <div class="product ">
                            <img src="images/Cherry.png" alt="Cherry">
                            <div class="image_overlay">
                            </div>
                            <div class="view_details">
                                Compare</div>
                            <div class="stats">
                                <div class="stats-container">
                                    <span class="product_price">
                                        $1.99</span>
                                    <span class="product_name">
                                        Cherry</span>
                                    <p>
                                    Two Cherries</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <div class="product ">
                            <img src="images/Orange.png" alt="Orange">
                            <div class="image_overlay">
                            </div>
                            <div class="view_details">
                                Compare</div>
                            <div class="stats">
                                <div class="stats-container">
                                    <span class="product_price">
                                        $2.99</span>
                                    <span class="product_name">
                                        Orange</span>
                                    <p>
                                    Giant Orange</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <div class="product ">
                            <img src="images/Nuts.png" alt="Nuts">
                            <div class="image_overlay">
                            </div>
                            <div class="view_details">
                                Compare</div>
                            <div class="stats">
                                <div class="stats-container">
                                    <span class="product_price">
                                        $1.00</span>
                                    <span class="product_name">
                                        Nuts</span>
                                    <p>
                                    Mixed Nuts</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <div class="product ">
                            <img src="images/Strawberry.png" alt="Strawberry">
                            <div class="image_overlay">
                            </div>
                            <div class="view_details">
                                Compare</div>
                            <div class="stats">
                                <div class="stats-container">
                                    <span class="product_price">
                                        $1.49</span>
                                    <span class="product_name">
                                        Strawberry</span>
                                    <p>
                                    Just Strawberry</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

```

> That's hardly semantic, Karen.

Same [`div` soup](https://www.pluralsight.com/blog/software-development/html5-web-components-overview) than what we had with [bootstrap components](https://getbootstrap.com/docs/3.3/components/#jumbotron).

Also, this div soup is not **isolated** from the rest of the DOM, and thus inherits CSS of its parents.

That's why some people invented [CSSInJS](https://cssinjs.org/); please forgive them.

### How to avoid the `div` soup

Create a Custom Element, and add a shadow root that you reference via `this.root` for example.

```js
// /js/endpoint.js

import {html, render, repeat, agent} from './index.js';

export class Endpoint extends HTMLElement {
    constructor() {
        super();
        this.root = this.attachShadow({mode: 'open'});
    }

    static get observedAttributes() { return ['url', 'title', 'description']; }

    attributeChangedCallback(name, old, val) {
        this.render();
    }

    connectedCallback() {
        this.render();
    }

    render() {
        render(html`
            <link rel="stylesheet" href="/css/endpoint.css"/>

            <pre>
                <code>
                    <slot name="response-body" @slotchange=${this.pretty.bind(this)}></slot>
                </code>
            </pre>

            <slot name="links"></slot>

            <slot name="operations"></slot>
        `, this.root);
    }

    pretty(event) {
        Array.from(event.target.assignedNodes()).map(node => node.textContent = JSON.stringify(JSON.parse(node.textContent), null, 2));
    }
}

customElements.define('h-endpoint', Endpoint);
```

Use it as a normal HTML element:

```html
<script type="module" src="/js/endpoint.js"></script>

<main>
    <h-endpoint method="POST">
        <pre slot="response-body">${this.resource.response.body}</pre>
    </h-endpoint>
</main>
```

Technically, you still want the same old html soup in order to build nice and stylable widgets, but you don't want to see it, nor having to copy it everywhere you want to reuse it.

That's where things like bootstrap components fall short: you have to copy-paste the whole div soup **everywhere** you want to reuse it.


With a Custom Element, you define it once and reuse it everywhere.  
With shadow DOM, you **hide** and **isolate** the div soup from its ancestors, gaining **CSS isolation** **AND** avoiding terrible experience viewing the HTML source.

Technically, the shadow DOM is still visible in DevTools, but hidden by default.  

Also, the shadow root is not a strict boundary. Even in `closed` mode, you could [technically see](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM#Basic_usage) the underlying div soup.


### How to keep the mouse focus?

Don't rewrite the DOM nodes while a user is focusing on it or he will **loose the focus**!

That's the complicated part: it's very hard to only refresh the parts of the DOM that are required.  
Hopefully some smart people wrote dom-diffing libraries for that. I personally use [lit-html](https://github.com/Polymer/lit-html).


```js
render(html`
    hello <input value="${user.name}" />
`, this.root);
```

This over-simplistic example is enough to show the importance of differential rendering.  
If instead of using `render(html`…`)`, you used `root.innerHTML = '…'`, the focus and the position of the cursor simply would be lost after each render! The number of browser repaints would also significantly increase.


### How to manipulate `<slot>` contents?

`<slot>` elements are great way to provide flexibility to the developer using your custom element.  
Under the hood, it's using [light dom](https://developers.google.com/web/fundamentals/web-components/shadowdom#lightdom).

Basically, light DOM is just a fragment of html that can be referenced elsewhere in the DOM. It's not really a copy, so it can seem weird.  
Firefox DevTools for example seems to be confused sometimes with light DOM.

First, define a slot named `response-body` (f.e) in your web component:

```html
<slot name="response-body" @slotchange=${this.pretty.bind(this)}>default content</slot>
```

Then simply add a tag with attribute `slot="response-body"`, and its content will replace the target slot in the web component.

```html
<h-endpoint method="POST">
    <pre slot="response-body">${this.resource.response.body}</pre>
</h-endpoint>
```

> Pro-tip: Seems like using auto-closing tags to declare slots is totally **not working**: ~~`<slot name="test" />`~~


Now that the content of the slot has been filled from the outside, how to programatically apply modifications to it?

Turns out there is a [javascript API](https://developer.mozilla.org/en-US/docs/Web/API/HTMLSlotElement/assignedNodes) for that.  
Let's try to pretty print the json content of the slot:

```js
pretty(event) {
    Array.from(event.target.assignedNodes()).map(node => node.textContent = JSON.stringify(JSON.parse(node.textContent), null, 2));
}
```

> This one was tricky: using `node.innerHTML` to retrieve the json string totally didn't work: it was always prefixed with `<!---->`!  
>
> ¯\\_(ツ)_/¯

### How to deploy your web components?

HTTP/2 is nearly [3 years old](https://www.ietf.org/blog/http2-approved/) and yet isn't still used at its full advantage.

People still rely on crazy bundlers like [webpack](https://webpack.js.org/) even tho H/2 could technically remove shit-tons of complexity while still maintaining good performances.  

It could even increase the cache HIT rate, by not having to invalidate a whole bundle for a single line of changed code.

My position here is to stop the madness and come back to the good old times where you had 200 script includes: it's better!  
Except that nowadays we have `<script type="module">` and ES imports. Use them!

You can provide an entrypoint at url `/js/index.js`:

```js
import {html, render} from '/node_modules/lit-html/lit-html.js';
import {repeat} from '/node_modules/lit-html/directives/repeat.js';
import {Endpoint} from './endpoint.js';

export function agent() {
    return window['@hippiemedia/agent'](client => (method, url, params, headers) => { // don't ask me
        return client(method, url, params, {Authorization: 'Bearer …', ...headers})
    });
}

export {html, render, repeat};
```

And then use it in good old html:


```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <script async type="module" src="/js/index.js"></script>
        <meta charset="UTF-8" />
        <link type="text/css" rel="stylesheet" href="/css/index.css" />
    </head>
    <body>
        <h-endpoint method="POST" title="Details of a user" url="/users/{user_id}" />
    </body>
</html>
```

### How to style a web component?


Add a `<link>` to a stylesheet **inside** your shadow root. By using an external resource, you increase your cache hit rate (as explained above).  
By linking the stylesheet inside the shadow root, the CSS will automatically be isolated!

Another cool advantage of this is that you can share css by simply linking a shared css document.

The interesting part is how CSS behaves and is controlled inside a shadow dom:

```css
:host {
    display: block;
    color: green;
    padding: 10px;
    margin: 10px;
    border: 1px solid black;
}

:host .delete {
    color: red;
}
```

The [`:host`](https://developer.mozilla.org/en-US/docs/Web/CSS/:host) pseudo-class represents your shadow dom.

You can also use [`:host-context()`](https://developer.mozilla.org/en-US/docs/Web/CSS/:host-context()) to apply css depending on your ancestors.  
So cool! But be careful not to couple yourself too much to the context.

If you want to provide an interface for styling your web components from the outside, you can define [CSS variables](https://www.carlrippon.com/providing-a-styling-api-for-web-components-via-css-custom-properties/).

