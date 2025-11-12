function getRandomSongNumber() {
  return (random = Math.floor(Math.random() * 3) + 1);
}

function setNewSong() {
  if (random == 1) {
    document.getElementById("loading").src = "song/song1.mp3";
    songname.innerHTML = "Broadway Girls - Lil Durk (Feat. Morgan Wallen)";
  } else if (random == 2) {
    document.getElementById("loading").src = "song/song2.mp3";
    songname.innerHTML = "Tweaker - GELO";
  } else if (random == 3) {
    document.getElementById("loading").src = "song/song3.mp3";
    songname.innerHTML = "Hero - Skillet";
  }
}

document.addEventListener("DOMContentLoaded", function () {
  var random = getRandomSongNumber();
  setNewSong(random);

  const slideshowImages = [
    "screenshots/41234.png",
    "screenshots/gfrheimage.png",
    "screenshots/image13.png",
    "screenshots/image66.png",
    "screenshots/qwreq.png",
    "screenshots/Screenshot_2025-10-12_210452.png",
    "screenshots/Screenshot_2025-10-16_041706.png",
    "screenshots/Screenshot_2025-10-24_183321.png",
    "screenshots/police_7.png",
  ];
  let currentSlide = 0;
  const slideshow = document.getElementById("slideshow");
  if (slideshowImages.length > 0) {
    slideshow.src = slideshowImages[0];
  }
  function showNextSlide() {
    currentSlide = (currentSlide + 1) % slideshowImages.length;
    slideshow.src = slideshowImages[currentSlide];
  }
  setInterval(showNextSlide, 5000);
});

var play = false;
var vid = document.getElementById("loading");
vid.volume = 0.1;
window.addEventListener("keyup", function (e) {
  if (e.which == 38) {
    vid.volume = Math.min(vid.volume + 0.025, 1);
  } else if (e.which == 40) {
    // ArrowUP
    vid.volume = Math.max(vid.volume - 0.025, 0);
  }
});

var mutetext = document.getElementById("text");
var songname = document.getElementById("songname");

window.addEventListener("keyup", function (event) {
  if (event.which == 37) {
    // ArrowLEFT
    if (document.getElementById("loading").src.endsWith("song2.mp3")) {
      document.getElementById("loading").src = "song/song1.mp3";
      songname.innerHTML = "Broadway Girls - Lil Durk (Feat. Morgan Wallen)";
    } else if (document.getElementById("loading").src.endsWith("song1.mp3")) {
      document.getElementById("loading").src = "song/song3.mp3";
      songname.innerHTML = "Hero - Skillet";
    } else if (document.getElementById("loading").src.endsWith("song3.mp3")) {
      document.getElementById("loading").src = "song/song2.mp3";
      songname.innerHTML = "Tweaker - GELO";
    }
    document.getElementById("loading").play();
    mutetext.innerHTML = "MUTE";
  }

  if (event.which == 39) {
    // ArrowRIGHT
    if (document.getElementById("loading").src.endsWith("song2.mp3")) {
      document.getElementById("loading").src = "song/song3.mp3";
      songname.innerHTML = "Hero - Skillet";
    } else if (document.getElementById("loading").src.endsWith("song3.mp3")) {
      document.getElementById("loading").src = "song/song1.mp3";
      songname.innerHTML = "Broadway Girls - Lil Durk (Feat. Morgan Wallen)";
    } else if (document.getElementById("loading").src.endsWith("song1.mp3")) {
      document.getElementById("loading").src = "song/song2.mp3";
      songname.innerHTML = "Tweaker - GELO";
    }
    document.getElementById("loading").play();
    mutetext.innerHTML = "MUTE";
  }
});

var audio = document.querySelector("audio");
if (audio) {
  window.addEventListener("keydown", function (event) {
    var key = event.which || event.keyCode;
    var x = document.getElementById("text").innerText;
    var y = document.getElementById("text");

    if (key === 32 && x == "MUTE") {
      // spacebar
      event.preventDefault();

      audio.paused ? audio.play() : audio.pause();
      y.innerHTML = "UNMUTE";
    } else if (key === 32 && x == "UNMUTE") {
      event.preventDefault();

      audio.paused ? audio.play() : audio.pause();
      y.innerHTML = "MUTE";
    }
  });
}
