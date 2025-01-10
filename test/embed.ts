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
