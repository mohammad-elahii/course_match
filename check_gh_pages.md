# GitHub Pages Configuration Check

Please follow these steps to ensure GitHub Pages is correctly configured:

1. Go to your repository settings:
   - Visit https://github.com/mohammad-elahii/course_match/settings

2. In the left sidebar, click on "Pages"

3. Under "Build and deployment":
   - Source: Select "Deploy from a branch" (not GitHub Actions)
   - Branch: Select "gh-pages" and "/ (root)"
   - Click "Save"

4. Wait a few minutes for the changes to take effect

5. Your website should now be available at:
   https://mohammad-elahii.github.io/course_match/

If you still see a 404 error, please check:
- The Actions tab to ensure the workflow completed successfully
- That the gh-pages branch contains the correct files (should have index.html and other Flutter web files) 