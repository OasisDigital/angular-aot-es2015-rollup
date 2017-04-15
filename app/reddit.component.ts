import { Component } from '@angular/core';
import { FormGroup, FormBuilder } from '@angular/forms';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/debounceTime';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/retry';
import 'rxjs/add/operator/switchMap';

import { RedditImageSearch, IRedditItem } from './redditImageSearch';

@Component({
  selector: 'reddit-images',
  templateUrl: './reddit.component.html'
})
export class RedditComponent {
  criteriaForm: FormGroup;
  results: Observable<IRedditItem[]>;

  constructor(ris: RedditImageSearch, fb: FormBuilder) {
    this.criteriaForm = fb.group({
      subReddit: ['aww'],
      search: ['']
    });

    const debouncedSearchTarget = this.criteriaForm.valueChanges
      .do(x => console.log('input changed', x))
      .debounceTime(500)
      .do(x => console.log('input changed (debounced), calling API', x));

    this.results = debouncedSearchTarget
      .switchMap(val => ris.search(val.subReddit, val.search)
        .retry(3))
      .catch(val => []) // show empty upon failure
      .do(x => console.log('results arrived'));
  }
}
