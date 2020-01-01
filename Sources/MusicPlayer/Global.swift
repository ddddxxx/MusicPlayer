//
//  Global.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim

public typealias Published = CXShim.Published
public typealias ObservableObject = CXShim.ObservableObject

#if canImport(AppKit)

import AppKit

public typealias Image = NSImage

#elseif canImport(UIKit)

import UIKit

public typealias Image = UIImage

#endif
