/**
 * Copyright 2007, 2008 Soggy Waffles
 *
 * This file is part of Paintbrush.
 *
 * Paintbrush is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Paintbrush is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Paintbrush; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */


#import "SWEllipseTool.h"

@implementation SWEllipseTool

- (NSBezierPath *)pathFromPoint:(NSPoint)begin toPoint:(NSPoint)end
{
	path = [NSBezierPath new];
	[path setLineWidth:lineWidth];
	[path setLineCapStyle:NSRoundLineCapStyle];
	[path moveToPoint:begin];
	if (lineWidth == 1) {
		begin.x += 0.5;
		begin.y += 0.5;
		end.x += 0.5;
		end.y += 0.5;
	}
	if (flags & NSShiftKeyMask) {
		double size = fmin(abs(end.x-begin.x),abs(end.y-begin.y));
		int x = (end.x-begin.x) / abs(end.x-begin.x);
		int y = (end.y-begin.y) / abs(end.y-begin.y);
		[path appendBezierPathWithOvalInRect:NSMakeRect(begin.x, begin.y, x*size, y*size)];
	} else {
		[path appendBezierPathWithOvalInRect:NSMakeRect(begin.x, begin.y, (end.x - begin.x), (end.y - begin.y))];
	}
	
	return path;	
}

- (void)performDrawAtPoint:(NSPoint)point withMainImage:(NSImage *)anImage secondImage:(NSImage *)secondImage mouseEvent:(SWMouseEvent)event
{	
	// Use the points clicked to build a redraw rectangle
	[super setRedrawRectFromPoint:savedPoint toPoint:point];
	
	// This loop removes all the representations in the overlay image, effectively clearing it
	for (NSImageRep *rep in [secondImage representations]) {
		[secondImage removeRepresentation:rep];
	}
	
	if (event == MOUSE_UP) {
		[NSApp sendAction:@selector(prepUndo:)
					   to:nil
					 from:nil];		
		drawToMe = anImage;
	} else {
		drawToMe = secondImage;
	}
	
	[drawToMe lockFocus]; 
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	
	
	
	if (shouldFill && shouldStroke) {
		[frontColor setStroke];
		[backColor setFill];
		[[self pathFromPoint:savedPoint toPoint:point] fill];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
	} else if (shouldFill) {
		[frontColor setFill];
		[[self pathFromPoint:savedPoint toPoint:point] fill];
	} else if (shouldStroke) {
		[frontColor setStroke];
		[[self pathFromPoint:savedPoint toPoint:point] stroke];
	}
	//NSLog(@"%@", drawToMe);
	[drawToMe unlockFocus];
}

- (NSString *)name
{
	return @"Ellipse";
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (BOOL)shouldShowFillOptions
{
	return YES;
}

@end