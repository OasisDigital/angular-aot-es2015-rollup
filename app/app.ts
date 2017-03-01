import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpModule } from '@angular/http';
import { ReactiveFormsModule } from '@angular/forms';

import { RedditComponent } from './reddit.component';
import { RedditImageSearch } from './redditImageSearch';

@NgModule({
  declarations: [
    RedditComponent
  ],
  imports: [
    BrowserModule,
    HttpModule,
    ReactiveFormsModule
  ],
  providers: [
    RedditImageSearch
  ],
  bootstrap: [RedditComponent]
})
export class AppModule { }
