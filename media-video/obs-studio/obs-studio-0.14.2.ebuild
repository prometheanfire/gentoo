# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit cmake-utils

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/jp9000/obs-studio.git"
	EGIT_SUBMODULES=()
else
	SRC_URI="https://github.com/jp9000/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Software for Recording and Streaming Live Video Content"
HOMEPAGE="https://obsproject.com"

LICENSE="GPL-2"
SLOT="0"
IUSE="+alsa fdk imagemagick jack pulseaudio truetype v4l"

DEPEND="
	>=dev-libs/jansson-2.5
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtquickcontrols:5
	dev-qt/qtsql:5
	dev-qt/qttest:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	media-libs/x264:=
	media-video/ffmpeg:=
	x11-libs/libXcomposite
	x11-libs/libXinerama
	x11-libs/libXrandr
	alsa? ( media-libs/alsa-lib )
	fdk? ( media-libs/fdk-aac:= )
	imagemagick? ( media-gfx/imagemagick:= )
	jack? ( virtual/jack )
	pulseaudio? ( media-sound/pulseaudio )
	truetype? (
		media-libs/fontconfig
		media-libs/freetype
	)
	v4l? ( media-libs/libv4l )
"
RDEPEND="${DEPEND}"

src_prepare() {
	CMAKE_REMOVE_MODULES_LIST=(FindFreetype)

	cmake-utils_src_prepare
}

src_configure() {
	local libdir="$(get_libdir)"
	local mycmakeargs=(
		-DDISABLE_ALSA="$(usex !alsa)"
		-DDISABLE_FREETYPE="$(usex !truetype)"
		-DDISABLE_JACK="$(usex !jack)"
		-DDISABLE_LIBFDK="$(usex !fdk)"
		-DDISABLE_PULSEAUDIO="$(usex !pulseaudio)"
		-DDISABLE_V4L2="$(usex !v4l)"
		-DLIBOBS_PREFER_IMAGEMAGICK="$(usex imagemagick)"
		-DOBS_MULTIARCH_SUFFIX="${libdir#lib}"
		-DUNIX_STRUCTURE=1
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	if ! use alsa && ! use pulseaudio; then
		elog "To be able to use the audio capture features, either the"
		elog "'alsa' or the 'pulseaudio' USE-flag needs to be enabled."
	fi
}
