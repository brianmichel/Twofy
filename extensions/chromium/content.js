const IS_DEV_MODE = !("update_url" in chrome.runtime.getManifest());

if (IS_DEV_MODE) {
  // If we're in dev, just show the banner just after loading a page.
  setTimeout(() => {
    showAutofill("223344");
  }, 1000);
}

chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
  if (request.action == "code") {
    showAutofill(request.data);
  }
});

function showAutofill(code) {
  let autofillElement = new TwoFactorAutofillCodeBanner(code);
}

// The main class in which 2FA autofill information will get presented.
// After instantiation this class will automatically try to present itself
// in the first input that it can find which matches the required attributes
// of `[type=text]` and `[inputmode=numeric]`
class TwoFactorAutofillCodeBanner {
  constructor(code) {
    this.showing = false;
    this.code = code;
    this.abortController = new AbortController();

    // Fetch all inputs that are of text and have a numeric input type
    // so that we filter down the list of potential inputs as the type
    // is extremely common and can trigger false positives.
    // TODO: Should we further filter this to look for a pattern?
    this.inputs = document.querySelectorAll(
      "input[type=text][inputmode=numeric]"
    );
    this.element = document.createElement("div");
    this.element.classList.add("twofy-banner");
    this.element.innerHTML = `
    <div class="twofy-autofill-container">
      <div class="twofy-autofill-content">
        <p class="twofy-code-icon"/>
        <div class="twofy-code-container">
          <p class="twofy-fill-code">Fill code <b>${this.code}</b></p>
          <p class="twofy-source-app">From Twofy</p>
        </div>
      </div>
    </div>
    `;
    this._insertAutofillElement(this.inputs);
    this.present();

    // Schedule the destruction of this banner in 10 seconds
    // after it is first presented.
    // TODO: How could/should this be adjustable?
    setTimeout(this.destroy.bind(this), 10_000);
  }

  present() {
    if (this.showing) {
      return;
    }
    this._show(this.inputs[0]);
    this.showing = true;
  }

  dismiss() {
    if (!this.showing) {
      return;
    }

    if (this.element) {
      this.element.removeEventListener("mousedown", this._insertCode);
      this.element.remove();
    }
    this.activeInputElement = null;
    this.showing = false;
  }

  destroy() {
    this.abortController.abort();
    this.dismiss();
    this.showing = false;
  }

  // SECTION: Internal Functions

  _insertAutofillElement(inputs) {
    inputs.forEach((input) => {
      input.addEventListener("focus", this.present.bind(this), {
        signal: this.abortController.signal,
      });
      input.addEventListener("blur", this.dismiss.bind(this), {
        signal: this.abortController.signal,
      });
      this._focusInputIfPossible(input);
    });
  }

  _focusInputIfPossible(input) {
    if (document.activeElement === input) {
      input.focus();
      input.dispatchEvent(new Event("focus"));
    }
  }

  _show(input) {
    this.activeInputElement = input;
    const inputClientRect = input.getBoundingClientRect();
    this.element.addEventListener(
      "mousedown",
      this._insertCode.bind(this),
      true
    );
    this.element.style.top = `${inputClientRect.bottom}px`;
    this.element.style.left = `${inputClientRect.left}px`;

    document.body.appendChild(this.element);

    this.element.classList.add("animate");
  }

  _insertCode(event) {
    if (this.activeInputElement) {
      this.activeInputElement.value = this.code;
    }

    this.dismiss();
  }
}
