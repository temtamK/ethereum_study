const DigitalPicture = artifacts.require("DigitalPicture");

contract("DigitalPicture", (accounts) => {
    const [owner] = accounts;

    beforeEach(async () => {
        this.token = await DigitalPicture.new();
    });

    it("should mint a token", async () => {
        const tokenId = await this.token.mintDigitalPicture(owner, "https://dev.sample.com/a/b/abc.jpg");
        console.log(tokenId);
    });
});