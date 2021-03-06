//
//  IPIProviderMapsCarouselViewController.m
//

#import "IPIProviderMapsCarouselViewController.h"
#import "TTTAttributedLabel.h"
#import "IPIProviderMapCarouselView.h"
#import "IPIPushNotificationRouter.h"

@implementation IPIProviderMapsCarouselViewController

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
        self.carousel.frame = CGRectMake(0, 0, 320, 90);
        [self.carousel setContentOffset:CGSizeMake(0, 0)];
        [self.carousel setCurrentItemIndex:0];
        [self.carousel setBounceDistance:0.05];
    }
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
}

-(void)refresh{
    self.currentPage = @1;
    if (self.loading) {
        return;
    }
    self.loading = YES;
    NSString * pageIDString = [NSString stringWithFormat:@"%@", self.page.remoteID];
    [[IPKHTTPClient sharedClient] getProvidersForPageWithId:pageIDString sortUser:nil success:^(AFJSONRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fetchedResultsController = nil;
            [self.carousel reloadData];
            self.loading = NO;
        });
    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SSRateLimit resetLimitForName:[NSString stringWithFormat:@"refresh-page-providers-%@", self.page.remoteID]];
            self.loading = NO;
        });
    }];
}

-(void)setPage:(IPKPage *)page{
    _page = page;
    
    self.fetchedResultsController = nil;
    
}

- (void)setSortUser:(IPKUser *)sortUser{
    _sortUser = sortUser;
    
	self.fetchedResultsController = nil;
	[self refresh];
    [self.carousel reloadData];	
}

-(NSString*)entityName{
    return @"IPKTeamMembership";
}

-(BOOL)ascending{
    return NO;
}

- (NSPredicate *)predicate {
    if (self.sortUser) {
        return [NSPredicate predicateWithFormat:@"team_id == %@ && owner_id == %@", self.page.remoteID, self.sortUser.remoteID];
    }else{
        return [NSPredicate predicateWithFormat:@"team_id == %@ && pollaverage == %@", self.page.remoteID, @(YES)];
    }
}


-(NSString *)sortDescriptors{
    return @"position";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context != (__bridge void *)self) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}

	if ([keyPath isEqualToString:@"title"]) {
		self.title = [change objectForKey:NSKeyValueChangeNewKey];
	} else if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && [keyPath isEqualToString:@"archivedAt"]) {
		if ([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) {
			[self.navigationController popToRootViewControllerAnimated:YES];
		}
	}
}

#pragma mark - iCarouselDataSource

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
//    if (self.fetchedResultsController.fetchedObjects.count == 0 || carousel.numberOfItems > self.fetchedResultsController.fetchedObjects.count){
//        return [self loadingViewWithFrame:CGRectMake(0, 0, 250, 150)];
//    }
    if (view == nil) {
        IPIProviderMapCarouselView * newView = [[IPIProviderMapCarouselView alloc] initWithFrame:CGRectMake(0, 0, 290, 90)];
        IPKProvider * provider = ((IPKTeamMembership*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).listing;
        [newView setProvider:provider];
        return newView;
    }
    else{
        [((IPIProviderMapCarouselView *)view) setProvider:((IPKTeamMembership*)[self.fetchedResultsController.fetchedObjects objectAtIndex:index]).listing];
    }
    return view;
}

#pragma mark - iCarouselDelegate

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    //override to stop loading cells from being added

}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel{
    
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    if (self.delegate) {
        [self.delegate pageChanged];
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel{
    
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate{
    
}

- (void)carouselWillBeginDecelerating:(iCarousel *)carousel{
    
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel{

}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index{

    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
//    IPKTeamMembership * tm = [[self.fetchedResultsController fetchedObjects] objectAtIndex:index];
//    NSNumber * providerID = tm.listing.remoteID;
//    NSString * listingType = tm.listing.listing_type;
//    UIViewController * vc = [IPIPushNotificationRouter viewControllerForProviderID:providerID listingType:listingType];
//    [self.parentViewController.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel{
    return 300;
}


//- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform{
//    
//}


//- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value{
//    switch (option)
//    {
//        case iCarouselOptionWrap:
//        {
//            return NO;
//        }
//        default:
//        {
//            return value;
//        }
//    }
//
//}

#pragma mark - NSFetchedResultsControllerDelegate


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.carousel reloadData];
}

@end
