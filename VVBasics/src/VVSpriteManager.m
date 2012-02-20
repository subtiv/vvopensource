
#import "VVSpriteManager.h"
#import "VVBasicMacros.h"




@implementation VVSpriteManager


/*===================================================================================*/
#pragma mark --------------------- create/destroy
/*------------------------------------*/
- (id) init	{
	//NSLog(@"%s",__func__);
	if (self = [super init])	{
		deleted = NO;
		spriteArray = [[MutLockArray alloc] initWithCapacity:0];
		spriteInUse = nil;
		spriteIndexCount = 1;
		return self;
	}
	[self release];
	return nil;
}
- (void) prepareToBeDeleted	{
	//NSLog(@"%s",__func__);
	[self removeAllSprites];
	deleted = YES;
}
- (void) dealloc	{
	//NSLog(@"%s",__func__);
	if (!deleted)
		[self prepareToBeDeleted];
	VVRELEASE(spriteArray);
	spriteInUse = nil;
	[super dealloc];
}


/*===================================================================================*/
#pragma mark --------------------- action and draw
/*------------------------------------*/


//	returns YES if the mousedown was on a sprite
- (BOOL) localMouseDown:(NSPoint)p	{
	//NSLog(@"%s",__func__);
	if ((deleted)||(spriteArray==nil)||([spriteArray count]<1))
		return NO;
	//	determine if there's a sprite which intersects the mousedown coords
	//NSEnumerator		*it;
	VVSprite		*spritePtr = nil;
	VVSprite		*foundSprite = nil;
	[spriteArray rdlock];
		for (spritePtr in [spriteArray array])	{
			if ((![spritePtr locked]) && ([spritePtr checkPoint:p]) && ([spritePtr actionCallback]!=nil) && ([spritePtr delegate]!=nil))	{
				foundSprite = spritePtr;
				break;
			}
		}
		/*
		it = [spriteArray objectEnumerator];
		while ((spritePtr = [it nextObject]) && (foundSprite==nil))	{
			if ((![spritePtr locked]) && ([spritePtr checkPoint:p]))
				foundSprite = spritePtr;
		}
		*/
	[spriteArray unlock];
	//	if i found a sprite which contains the mousedown loc
	if (foundSprite!=nil)	{
		spriteInUse = foundSprite;
		[foundSprite mouseDown:p];
		return YES;
	}
	//	if i'm here, i didn't find a sprite- return NO
	return NO;
}
- (BOOL) localRightMouseDown:(NSPoint)p	{
	if ((deleted)||(spriteArray==nil)||([spriteArray count]<1))
		return NO;
	//	determine if there's a sprite which intersects the mousedown coords
	//NSEnumerator		*it;
	VVSprite		*spritePtr = nil;
	VVSprite		*foundSprite = nil;
	[spriteArray rdlock];
		for (spritePtr in [spriteArray array])	{
			if ((![spritePtr locked]) && ([spritePtr checkPoint:p]) && ([spritePtr actionCallback]!=nil) && ([spritePtr delegate]!=nil))	{
				foundSprite = spritePtr;
				break;
			}
		}
		/*
		it = [spriteArray objectEnumerator];
		while ((spritePtr = [it nextObject]) && (foundSprite==nil))	{
			if ((![spritePtr locked]) && ([spritePtr checkPoint:p]))
				foundSprite = spritePtr;
		}
		*/
	[spriteArray unlock];
	//	if i found a sprite which contains the mousedown loc
	if (foundSprite!=nil)	{
		spriteInUse = foundSprite;
		[foundSprite rightMouseDown:p];
		return YES;
	}
	//	if i'm here, i didn't find a sprite- return NO
	return NO;
}
- (void) localRightMouseUp:(NSPoint)p	{
	if ((deleted)||(spriteInUse==nil))
		return;
	[spriteInUse rightMouseUp:p];
	spriteInUse = nil;
}
- (void) localMouseDragged:(NSPoint)p	{
	//NSLog(@"%s",__func__);
	if ((deleted)||(spriteInUse==nil))
		return;
	[spriteInUse mouseDragged:p];
}
- (void) localMouseUp:(NSPoint)p	{
	//NSLog(@"%s",__func__);
	if ((deleted)||(spriteInUse==nil))
		return;
	[spriteInUse mouseUp:p];
	spriteInUse = nil;
}

/*===================================================================================*/
#pragma mark --------------------- management
/*------------------------------------*/

- (VVSprite *) spriteAtPoint:(NSPoint)p	{
	//NSLog(@"%s ... (%f, %f)",__func__,p.x,p.y);
	if (deleted)
		return nil;
		
	id	returnMe = nil;
	
	[spriteArray rdlock];
	
		for (VVSprite *tmpSprite in [spriteArray array])	{
			if ((![tmpSprite locked]) && ([tmpSprite checkPoint:p]))	{
				returnMe = tmpSprite;		
				break;
			}
		}
	
	[spriteArray unlock];
	
	return returnMe;
}
- (VVSprite *) visibleSpriteAtPoint:(NSPoint)p	{
	//NSLog(@"%s ... (%f, %f)",__func__,p.x,p.y);
	if (deleted)
		return nil;
		
	id	returnMe = nil;
	
	[spriteArray rdlock];
	
		for (VVSprite *tmpSprite in [spriteArray array])	{
			if ((![tmpSprite locked]) && (![tmpSprite hidden]) && ([tmpSprite checkPoint:p]))	{
				returnMe = tmpSprite;		
				break;
			}
		}
	
	[spriteArray unlock];
	
	return returnMe;
}
- (id) newSpriteAtBottomForRect:(NSRect)r	{
	if (deleted)
		return nil;
	id			returnMe = nil;
	returnMe = [VVSprite createWithRect:r inManager:self];
	[spriteArray lockAddObject:returnMe];
	return returnMe;
}
- (id) newSpriteAtTopForRect:(NSRect)r	{
	if (deleted)
		return nil;
	id			returnMe = nil;
	returnMe = [VVSprite createWithRect:r inManager:self];
	[spriteArray lockInsertObject:returnMe atIndex:0];
	return returnMe;
}
- (long) getUniqueSpriteIndex	{
	if (deleted)
		return -1;
	long		returnMe = spriteIndexCount;
	++spriteIndexCount;
	if (spriteIndexCount >= 0x7FFFFFFF)
		spriteIndexCount = 1;
	return returnMe;
}

- (VVSprite *) spriteForIndex:(long)i	{
	if (deleted)
		return nil;
	//NSEnumerator		*it;
	VVSprite		*spritePtr = nil;
	VVSprite		*returnMe = nil;
	
	[spriteArray rdlock];
	for (spritePtr in [spriteArray array])	{
		if ([spritePtr spriteIndex] == i)	{
			returnMe = spritePtr;
			break;
		}
	}
	/*
	it = [spriteArray objectEnumerator];
	while ((spritePtr = [it nextObject]) && (returnMe == nil))	{
		if ([spritePtr spriteIndex] == i)
			returnMe = spritePtr;
	}
	*/
	[spriteArray unlock];
	return returnMe;
}
- (void) removeSpriteForIndex:(long)i	{
	if (deleted)
		return;
	//NSEnumerator		*it;
	int				tmpIndex = 0;
	VVSprite		*spritePtr;
	VVSprite		*foundSprite = nil;
	
	//	find & remove sprite in sprites array
	[spriteArray wrlock];
	for (spritePtr in [spriteArray array])	{
		if ([spritePtr spriteIndex] == i)	{
			foundSprite = spritePtr;
			break;
		}
		++tmpIndex;
	}
	if (foundSprite != nil)	{
		if (spriteInUse == foundSprite)
			spriteInUse = nil;
		[spriteArray removeObjectAtIndex:tmpIndex];
	}
	/*
	it = [spriteArray objectEnumerator];
	while ((spritePtr=[it nextObject])&&(foundSprite==nil))	{
		if ([spritePtr spriteIndex]==i)
			foundSprite = spritePtr;
	}
	if (foundSprite!=nil)
		[spriteArray removeObject:foundSprite];
	*/
	[spriteArray unlock];
	/*
	//	find & remove sprite in sprites in use array
	if (spriteInUse == foundSprite)
		spriteInUse = nil;
	*/
}
- (void) removeSprite:(id)z	{
	if (deleted || z==nil)
		return;
	if ((spriteArray!=nil)&&([spriteArray count]>0))	{
		//[spriteArray lockRemoveObject:z];
		[spriteArray lockRemoveIdenticalPtr:z];
	}
	if (spriteInUse == z)
		spriteInUse = nil;
}
- (void) removeSpritesFromArray:(NSArray *)array	{
	if (deleted || array==nil)
		return;
	for (id sprite in array)	{
		[self removeSprite:sprite];
	}
}
- (void) removeAllSprites	{
	if (deleted)
		return;
	//	remove everything from the tracker array
	spriteInUse = nil;
	//	remove everything from the sprites in use array
	if (spriteArray != nil)
		[spriteArray lockRemoveAllObjects];
}
/*
- (void) moveSpriteToFront:(VVSprite *)z	{
	//NSLog(@"%s",__func__);
	if ((deleted)||(spriteArray==nil)||([spriteArray count]<1))
		return;
	[spriteArray wrlock];
		
		[spriteArray removeObject:z];
		[spriteArray insertObject:z atIndex:0];
		
	[spriteArray unlock];
}
*/
- (void) draw	{
	//NSLog(@"%s",__func__);
	if ((deleted)||(spriteArray==nil)||([spriteArray count]<1))
		return;
	[spriteArray rdlock];
		NSEnumerator	*it = [[spriteArray array] reverseObjectEnumerator];
		VVSprite	*spritePtr;
		while (spritePtr = [it nextObject])	{
			//if (![spritePtr hidden])
				[spritePtr draw];
		}
	[spriteArray unlock];
}
- (void) drawRect:(NSRect)r	{
	//NSLog(@"%s",__func__);
	if ((deleted)||(spriteArray==nil)||([spriteArray count]<1))
		return;
	[spriteArray rdlock];
		NSEnumerator	*it = [[spriteArray array] reverseObjectEnumerator];
		VVSprite	*spritePtr;
		while (spritePtr = [it nextObject])	{
			//NSRect		tmp = [spritePtr rect];
			//NSLog(@"\t\tsprite %@ is (%f, %f) %f x %f",[spritePtr userInfo],tmp.origin.x,tmp.origin.y,tmp.size.width,tmp.size.height);
			//if (![spritePtr hidden])	{
				if (NSIntersectsRect([spritePtr rect],r))
					[spritePtr draw];
			//}
		}
	[spriteArray unlock];
}

- (VVSprite *) spriteInUse	{
	if (deleted)
		return nil;
	return spriteInUse;
}
- (void) setSpriteInUse:(VVSprite *)z	{
	if (deleted)
		return;
	spriteInUse = z;
}
- (MutLockArray *) spriteArray	{
	return spriteArray;
}


@end
