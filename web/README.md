# Installing Quarto
- Go to [https://quarto.org/](https://quarto.org/) and install the latest version of the Quarto command line interface (CLI) tool.
- You can use whatever GUI you are most comfortable with, but I recommend following the instructions for VS Code.


# How to update the site

- Add the files for the website are in the `/web/` subdirectory.
- Make any edits and then commit to the respository.
- To update the site, navigate to the `/web/` subdirectory in the command line and then run `quarto publish`. (Note: You should be on the branch `main` when you do this.) This will render the site locally and then automatically push to the `gh-pages` branch and update the GitHub Pages website. The GitHub repository has already been configured to publish from the root of the `gh-pages` branch.

For more detailed information, check out the instructions [here](https://quarto.org/docs/publishing/github-pages.html#publish-command).

Note [JB]: As of 4/29/23, the only way to update the site is by running `quarto publish`.
However, in the future I'd like to implement a GitHub action to automatically deploy.
