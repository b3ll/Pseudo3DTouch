# PDPseudo3DTouchGestureRecognizer

**Disclaimer**: PS don't break your screen pls :)

A yolo implementation of a 3D gesture recognizer using UITouch's -majorRadius property for comparing the differences in touch radii.

Definitely not prime for shipping I wrote it just for demo purposes, but it's fun to mess with. Use it to get a feel for how 3D touch will be! :D

Was built for my presentation at [NSSpain 2015](http://www.nsspain.com), so be sure to check out my talk [here](https://vimeo.com/145048167)! :D 

Also, it's not super amazingly accurate, but it gets the job done. Helps sometimes to change the angle of your thumb or finger when pressing harder.

Depth values scale from 1 -> infinity, the scale isn't really unbound.

Example includes a bouncing circle with pseudo "taptic feedback" based on how hard you press the screen.

### How do I compile?
Xcode pretty much.

### License?
Pretty much the BSD license, just don't repackage it and call it your own please!

Also if you do make some changes, feel free to make a pull request and help make things more awesome!

### Contact Info?

Feel free to follow me on twitter: [@b3ll](https://www.twitter.com/b3ll)!
