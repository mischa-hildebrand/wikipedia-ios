//
//  WMFExploreSectionSchemaTests.m
//  Wikipedia
//
//  Created by Brian Gerstle on 2/23/16.
//  Copyright © 2016 Wikimedia Foundation. All rights reserved.
//

@import Quick;
@import Nimble;

#import "WMFExploreSection.h"
#import "WMFExploreSectionSchema_Testing.h"
#import "MWKDataStore+TemporaryDataStore.h"
#import "MWKSite.h"
#import "WMFRandomFileUtilities.h"
#import "WMFRelatedSectionBlacklist.h"
#import "WMFMockLocationManager.h"
#import "NSDate+Utilities.h"

QuickSpecBegin(WMFExploreSectionSchemaTests)

__block WMFExploreSectionSchema* schema;
__block MWKDataStore* dataStore;
__block WMFMockLocationManager* mockLocationManager;

// Convenience setup method which creates a schema for the given site, injecting mocks & temporary stores for other fields.
void(^setupSchemaWithSite)(MWKSite*) = ^(MWKSite* site) {
    // TODO: setup w/ temp blacklist
    schema = [WMFExploreSectionSchema schemaWithSite:site
                                          savedPages:dataStore.userDataStore.savedPageList
                                             history:dataStore.userDataStore.historyList
                                           blackList:[WMFRelatedSectionBlackList new]
                                     locationManager:mockLocationManager
                                                file:WMFRandomTemporaryFileOfType(@"plist")];
};

beforeEach(^{
    dataStore = [MWKDataStore temporaryDataStore];
    mockLocationManager = [WMFMockLocationManager new];
});

afterEach(^{
    [dataStore removeFolderAtBasePath];
    [[NSFileManager defaultManager] removeItemAtPath:schema.filePath error:nil];
});

describe(@"initial state", ^{
    __block MWKSite* site;

    context(@"en wiki", ^{
        beforeEach(^{
            site = [MWKSite siteWithLanguage:@"en"];
        });

        context(@"clean install, location allowed", ^{
            beforeEach(^{
                [mockLocationManager setLocation:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
            });

            it(@"should contain everything except 'because you read' sections", ^{
                setupSchemaWithSite(site);
                expect([schema.sections valueForKey:WMF_SAFE_KEYPATH([WMFExploreSection new], type)])
                .withTimeout(5)
                .toEventually(equal(@[@(WMFExploreSectionTypeFeaturedArticle),
                                      @(WMFExploreSectionTypeMostRead),
                                      @(WMFExploreSectionTypeMainPage),
                                      @(WMFExploreSectionTypePictureOfTheDay),
                                      @(WMFExploreSectionTypeRandom),
                                      @(WMFExploreSectionTypeNearby)]));

                WMFExploreSection* featuredArticleSection = schema.sections[0];
                expect(@(featuredArticleSection.type)).to(equal(@(WMFExploreSectionTypeFeaturedArticle)));
                expect(featuredArticleSection.site).to(equal(site));
                expect(@([featuredArticleSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* mostReadSection = schema.sections[1];
                expect(@(mostReadSection.type)).to(equal(@(WMFExploreSectionTypeMostRead)));
                expect(mostReadSection.site).to(equal(site));
                // not asserting most read section date, see WMFMostReadDateTests

                WMFExploreSection* mainPageSection = schema.sections[2];
                expect(@(mainPageSection.type)).to(equal(@(WMFExploreSectionTypeMainPage)));
                expect(mainPageSection.site).to(equal(site));
                expect(@([mainPageSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* potdSection = schema.sections[3];
                expect(@(potdSection.type)).to(equal(@(WMFExploreSectionTypePictureOfTheDay)));
                expect(@([potdSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* randomSection = schema.sections[4];
                expect(@(randomSection.type)).to(equal(@(WMFExploreSectionTypeRandom)));
                expect(@([randomSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* nearbySection = schema.sections[5];
                expect(@(nearbySection.type)).to(equal(@(WMFExploreSectionTypeNearby)));
                expect(nearbySection.location).to(equal(mockLocationManager.location));
                expect(@([nearbySection.dateCreated isToday])).to(beTrue());
            });
        });

        context(@"clean install, no location", ^{
            it(@"should contain everything except 'because you read', continue reading, and location sections", ^{
                setupSchemaWithSite(site);
                expect([schema.sections valueForKey:WMF_SAFE_KEYPATH([WMFExploreSection new], type)])
                .withTimeout(5)
                .toEventually(equal(@[@(WMFExploreSectionTypeFeaturedArticle),
                                      @(WMFExploreSectionTypeMostRead),
                                      @(WMFExploreSectionTypeMainPage),
                                      @(WMFExploreSectionTypePictureOfTheDay),
                                      @(WMFExploreSectionTypeRandom)]));

                WMFExploreSection* featuredArticleSection = schema.sections[0];
                expect(@(featuredArticleSection.type)).to(equal(@(WMFExploreSectionTypeFeaturedArticle)));
                expect(featuredArticleSection.site).to(equal(site));
                expect(@([featuredArticleSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* mostReadSection = schema.sections[1];
                expect(@(mostReadSection.type)).to(equal(@(WMFExploreSectionTypeMostRead)));
                expect(mostReadSection.site).to(equal(site));
                // not asserting most read section date, see WMFMostReadDateTests

                WMFExploreSection* mainPageSection = schema.sections[2];
                expect(@(mainPageSection.type)).to(equal(@(WMFExploreSectionTypeMainPage)));
                expect(mainPageSection.site).to(equal(site));
                expect(@([mainPageSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* potdSection = schema.sections[3];
                expect(@(potdSection.type)).to(equal(@(WMFExploreSectionTypePictureOfTheDay)));
                expect(@([potdSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* randomSection = schema.sections[4];
                expect(@(randomSection.type)).to(equal(@(WMFExploreSectionTypeRandom)));
                expect(@([randomSection.dateCreated isToday])).to(beTrue());
            });
        });
    });

    context(@"es wiki", ^{
        beforeEach(^{
            site = [MWKSite siteWithLanguage:@"es"];
        });

        context(@"clean install, with location", ^{
            beforeEach(^{
                [mockLocationManager setLocation:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
            });

            it(@"should contain same as EN wiki, minus featured article", ^{
                setupSchemaWithSite(site);
                expect([schema.sections valueForKey:WMF_SAFE_KEYPATH([WMFExploreSection new], type)])
                .withTimeout(5)
                .toEventually(equal(@[@(WMFExploreSectionTypeMostRead),
                                      @(WMFExploreSectionTypeMainPage),
                                      @(WMFExploreSectionTypePictureOfTheDay),
                                      @(WMFExploreSectionTypeRandom),
                                      @(WMFExploreSectionTypeNearby)]));


                WMFExploreSection* mostReadSection = schema.sections[0];
                expect(@(mostReadSection.type)).to(equal(@(WMFExploreSectionTypeMostRead)));
                expect(mostReadSection.site).to(equal(site));
                // not asserting most read section date, see WMFMostReadDateTests

                WMFExploreSection* mainPageSection = schema.sections[1];
                expect(@(mainPageSection.type)).to(equal(@(WMFExploreSectionTypeMainPage)));
                expect(mainPageSection.site).to(equal(site));
                expect(@([mainPageSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* potdSection = schema.sections[2];
                expect(@(potdSection.type)).to(equal(@(WMFExploreSectionTypePictureOfTheDay)));
                expect(@([potdSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* randomSection = schema.sections[3];
                expect(@(randomSection.type)).to(equal(@(WMFExploreSectionTypeRandom)));
                expect(@([randomSection.dateCreated isToday])).to(beTrue());

                WMFExploreSection* nearbySection = schema.sections[4];
                expect(@(nearbySection.type)).to(equal(@(WMFExploreSectionTypeNearby)));
                expect(nearbySection.location).to(equal(mockLocationManager.location));
                expect(@([nearbySection.dateCreated isToday])).to(beTrue());
            });
        });
    });
});

describe(@"persistence", ^{
    pending(@"it should persist changes", ^{});
});

QuickSpecEnd
