declare type Func = () => void;
declare type AsyncFunc = () => Promise<void>;

declare type TestRunContext = {
  chromium_version: number;
};

declare type ItFunc = (ctx: TestRunContext) => void;
declare type ItAsyncFunc = (ctx: TestRunContext) => Promise<void>;

declare type Fn = (fn: Func | AsyncFunc) => void;
declare type Decl = (description: string, fn: Func | AsyncFunc) => void;
declare type ItDecl = (description: string, fn: ItFunc | ItAsyncFunc) => void;

declare type TestSettings = {
  threshold?: number;
  retries?: number;
};

declare type It = ItDecl & {
  skip: Decl;
  allowing: (settings: number | TestSettings) => Decl;
  dpr: (dpr: number) => Decl;
  no_image: Decl;
};

declare const describe: Decl;
declare const it: It;

// Start of tests

describe("describe", () => {
  it("it-1", () => {
    return true;
  });

  describe("sub-describe", () => {
    it("it-2", async () => {
      return false;
    });
  });
});
