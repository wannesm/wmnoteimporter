#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h> 

#import <Foundation/Foundation.h>

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports
  
   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes 
   that your importer can handle
  
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2 
   Implement the GetMetadataForFile function
  
   Implement the GetMetadataForFile function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional) 
   If you have defined new attributes, update the schema.xml file
  
   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.
  
   Add any custom types that your importer requires to the <attributes> element
  
   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
  
   ----------------------------------------------------------------------------- */



/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

Boolean GetMetadataForFile(
									void* thisInterface, 
									CFMutableDictionaryRef attributes, 
									CFStringRef contentTypeUTI,
									CFStringRef pathToFile)
{
	/* Pull any available metadata from the file at the specified path */
	/* Return the attribute keys and attribute values in the dict */
	/* Return TRUE if successful, FALSE if there was no data provided */
	BOOL success = NO;
	NSAutoreleasePool *pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	//NSLog(@"Starting Wannesm Note importer");
	
	NSString *note = [[NSString alloc] initWithContentsOfFile:(NSString *)pathToFile];
	//NSArray *arrayOfLines = [note componentsSeparatedByString:@"\n"];
	if (note)
	{
		//NSLog(@"note is:");
		//NSLog(note);
		
		NSString *title, *key, *value;
		
		NSScanner *scanner = [NSScanner scannerWithString:note];
		
		// first line is title
		[scanner scanUpToString:@"\n" intoString:&title];
		
		//NSLog(@"Title:");
		//NSLog(title);
		
		[(NSMutableDictionary *)attributes setObject:title 
														  forKey:(NSString *)kMDItemTitle];
		[(NSMutableDictionary *)attributes setObject:title 
														  forKey:(NSString *)kMDItemSubject];
		[(NSMutableDictionary *)attributes setObject:title 
														  forKey:(NSString *)kMDItemDescription];
		[(NSMutableDictionary *)attributes setObject:title 
														  forKey:(NSString *)kMDItemDisplayName];
		
		
		[scanner scanUpToString:@"@" intoString:nil]; // find first @
		
		while (![scanner isAtEnd])
		{
			//NSLog(@"metadata found");
			
			[scanner scanString:@"@" intoString:nil];
			[scanner scanUpToString:@" " intoString:&key];
			
			//NSLog(@"key:");
			//NSLog(key);
			
			[scanner scanString:@" " intoString:nil];
			[scanner scanUpToString:@"\n" intoString:&value];
			
			//NSLog(@"value:");
			//NSLog(value);
			
			if ([key isEqualToString:@"keywords"])
			{
				[(NSMutableDictionary *)attributes setObject:[[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "] 
																  forKey:(NSString *)kMDItemKeywords];
			}
			else if ([key isEqualToString:@"date"]) {
				//NSLog(@"It's a date");
				//				[(NSMutableDictionary *)attributes setObject:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] 
				//													  forKey:(NSString *)@"com_wannesm_notes_note_date"];
				
				// YYYY-MM-DD HH:MM:SS ±HHMM)
				NSMutableString *datestr = [NSMutableString stringWithCapacity:20]; 
				value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				[datestr insertString:[value substringWithRange:NSMakeRange(0, 4)] atIndex:0];
				[datestr insertString:@"-" atIndex:4];
				if ([value length] > 4) {
					[datestr insertString:[value substringWithRange:NSMakeRange(4, 2)] atIndex:5];
				} else {
					[datestr insertString:@"01" atIndex:5];
				}
				[datestr insertString:@"-" atIndex:7];
				if ([value length] > 6) {
					[datestr insertString:[value substringWithRange:NSMakeRange(6, 2)] atIndex:8];
				} else {
					[datestr insertString:@"01" atIndex:8];
				}
				[datestr insertString:@" 12:00:00 +0100" atIndex:10];
				
				// NSLog(datestr);
				NSDate *date = [NSDate dateWithString:datestr];
				
				// kMDItemLastUsedDate
				[(NSMutableDictionary *)attributes setObject:date
																  forKey:(NSString *)kMDItemLastUsedDate];
				// kMDItemContentCreationDate
				[(NSMutableDictionary *)attributes setObject:date
																  forKey:(NSString *)kMDItemContentCreationDate];
				// kMDItemFSCreationDate
				[(NSMutableDictionary *)attributes setObject:date
																  forKey:(NSString *)kMDItemFSCreationDate];
			}
			else if ([key isEqualToString:@"people"]) {
				// NSLog(@"It's a person");
				[(NSMutableDictionary *)attributes setObject:[[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "] 
																  forKey:(NSString *)kMDItemContributors];
			}
			else if ([key isEqualToString:@"project"]) {
				//NSLog(@"It's a project");
				[(NSMutableDictionary *)attributes setObject:[[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@" "] 
																  forKey:(NSString *)kMDItemProjects];
			}
			
			[scanner scanUpToString:@"@" intoString:nil]; // find next @
			
		}
		
		
		//NSLog(@"Note:");
		//NSLog(note);
		
		[(NSMutableDictionary *)attributes setObject:note 
														  forKey:(NSString *)kMDItemTextContent];
		success = YES;
		//[scanner release];
	}
	
	//NSLog(@"Releasing pool");
	[pool release];
	
	//NSLog(@"Returning success");
	return(success);;
}