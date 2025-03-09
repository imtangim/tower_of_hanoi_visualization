# 6. README.md
# Tower of Hanoi Recursion Visualizer

A Flutter web application that visualizes the Tower of Hanoi algorithm and its recursive solution.

## Features

- Interactive visualization of the Tower of Hanoi puzzle
- Step-by-step animation of the recursive algorithm
- Visual code execution highlighting
- Adjustable animation speed
- Responsive design for both desktop and mobile

## How to Use

1. Visit the live demo: https://imtangim.github.io/tower_of_hanoi_visualizer/
2. Click the "Solve" button to start the animation
3. Use the speed slider to adjust the animation speed
4. Click "Reset" to reset the puzzle

## Technical Details

- Built with Flutter for web
- Uses GetX for state management
- Deployed to GitHub Pages

## Development

To run this project locally:

```bash
flutter pub get
flutter run -d chrome
```

To build for web deployment:

```bash
flutter build web --base-href /tower_of_hanoi_visualizer/
```
