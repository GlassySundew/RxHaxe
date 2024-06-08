package rx;

import haxe.extern.EitherType;
import haxe.Constraints.Function;
import rx.observables.BufferWhen;
import rx.observables.BufferCount;
import rx.Core.RxObserver;
import rx.Core.RxSubscription;
// Creating Observables
import rx.observables.Create;
// create an Observable from scratch by calling observer methods programmatically
import rx.observables.Defer;
//  — do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
import rx.observables.Empty;
import rx.observables.Never;
import rx.observables.Error;
//  — create Observables that have very precise and limited behavior
// From;// — convert some other object or data structure into an Observable
// Interval;//  — create an Observable that emits a sequence of integers spaced by a particular time interval
// Just;//  — convert an object or a set of objects into an Observable that emits that or those objects
// Range;//  — create an Observable that emits a range of sequential integers
// Repeat;//  — create an Observable that emits a particular item or sequence of items repeatedly
// Start;//  — create an Observable that emits the return value of a function
// Timer;//  — create an Observable that emits a single item after a given delay
import rx.observables.Empty;
import rx.observables.Error;
import rx.observables.Never;
import rx.observables.Return;
import rx.observables.Append;
import rx.observables.Dematerialize;
import rx.observables.Skip;
import rx.observables.Length;
import rx.observables.Map;
import rx.observables.Materialize;
import rx.observables.Merge;
import rx.observables.Single;
import rx.observables.Take;
import rx.observables.TakeLast;
// 7-31
import rx.observables.Average;
import rx.observables.Amb;
import rx.observables.Buffer;
import rx.observables.Catch;
import rx.observables.CombineLatest;
import rx.observables.Concat;
import rx.observables.Contains;
// 8-1
import rx.observables.Defer;
import rx.observables.Create;
import rx.observables.Throttle;
import rx.observables.DefaultIfEmpty;
import rx.observables.Timestamp;
import rx.observables.Delay;
import rx.observables.Distinct;
import rx.observables.DistinctUntilChanged;
import rx.observables.Filter;
import rx.observables.Find;
import rx.observables.ElementAt;
// 8-2
import rx.observables.First;
import rx.observables.Last;
import rx.observables.IgnoreElements;
import rx.observables.SkipUntil;
import rx.observables.Scan;
// 8-3
import rx.observables.TakeUntil;
import rx.observables.MakeScheduled;
import rx.observables.Blocking;
import rx.observables.CurrentThread;
import rx.observables.Immediate;
import rx.observables.NewThread;
import rx.observables.Test;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.schedulers.IScheduler;

typedef Signal<T> = {
	function add<T>( callback : ( T ) -> Void ) : Signal<T>;
	function remove<T>( callback : EitherType<Bool, ( T ) -> Void> ) : Void;
}

class ObservableFactory {

	static public function find<T>( observable : Observable<T>, comparer : Null<T -> Bool> ) {
		return new Find( observable, comparer );
	}

	static public function filter<T>( observable : Observable<T>, comparer : Null<T -> Bool> ) {
		return new Filter( observable, comparer );
	}

	static public function distinctUntilChanged<T>( observable : Observable<T>, ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new DistinctUntilChanged( observable, comparer );
	}

	static public function distinct<T>( observable : Observable<T>, ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new Distinct( observable, comparer );
	}

	static public function delay<T>( source : Observable<T>, dueTime : Float, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Delay<T>( source, haxe.Timer.stamp() + dueTime, scheduler );
	}

	static public function timestamp<T>( source : Observable<T>, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Timestamp<T>( source, scheduler );
	}

	static public function scan<T, R>( observable : Observable<T>, seed : Null<R>, accumulator : R -> T -> R ) {
		return new Scan( observable, seed, accumulator );
	}

	static public function last<T>( observable : Observable<T>, ?source : Null<T> ) {
		return new Last( observable, source );
	}

	static public function first<T>( observable : Observable<T>, ?source : Null<T> ) {
		return new First( observable, source );
	}

	static public function defaultIfEmpty<T>( observable : Observable<T>, source : T ) {
		return new DefaultIfEmpty( observable, source );
	}

	static public function contains<T>( observable : Observable<T>, source : T ) {
		return new Contains( observable, function ( v ) return v == source );
	}

	static public function concat<T>( observable : Observable<T>, source : Array<Observable<T>> ) {
		return new Concat( [observable].concat( source ) );
	}

	static public function combineLatest<T, R>( observable : Observable<T>, source : Array<Observable<T>>, combinator : Array<T> -> R ) {
		return new CombineLatest( [observable].concat( source ), combinator );
	}

	static public function of_catch<T>( observable : Observable<T>, errorHandler : String -> Observable<T> ) {
		return new Catch( observable, errorHandler );
	}

	static public function bufferWhen<T>( observable : Observable<T>, closingSelector : () -> IObservable<T> ) {
		return new BufferWhen( observable, closingSelector );
	}

	static public function bufferCount<T>( observable : Observable<T>, count : Int ) {
		return new BufferCount( observable, count );
	}

	static public function observer<T>( observable : Observable<T>, fun : T -> Void ) {
		return observable.subscribe( Observer.create( null, null, fun ) );
	}

	static public function amb<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new Amb( observable1, observable2 );
	}

	static public function average<T>( observable : Observable<T> ) {
		return new Average( observable );
	}

	static public function materialize<T>( observable : Observable<T> ) {
		return new Materialize( observable );
	}

	static public function dematerialize<T>( observable : Observable<Notification<T>> ) {
		return new Dematerialize( observable );
	}

	static public function length<T>( observable : Observable<T> ) {
		return new Length( observable );
	}

	static public function drop<T>( observable : Observable<T>, n : Int ) {
		return skip( observable, n );
	}

	static public function skip<T>( observable : Observable<T>, n : Int ) {
		return new Skip( observable, n );
	}

	static public function skip_until<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new SkipUntil( observable1, observable2 );
	}

	static public function take<T>( observable : Observable<T>, n : Int ) {
		return new Take( observable, n );
	}

	static public function take_until<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new TakeUntil( observable1, observable2 );
	}

	static public function take_last<T>( observable : Observable<T>, n : Int ) {
		return new TakeLast( observable, n );
	}

	static public function single<T>( observable : Observable<T> ) {
		return new Single( observable );
	}

	static public function append<T>( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new Append( observable1, observable2 );
	}

	static public function map<T, R>( observable : Observable<T>, f : T -> R ) {
		return new Map( observable, f );
	}

	static public function merge<T>( observable : Observable<Observable<T>> ) {
		return new Merge( observable );
	}

	static public function flatMap<T, R>( observable : Observable<T>, f : T -> Observable<R> ) {
		return bind( observable, f );
	}

	static public function bind<T, R>( observable : Observable<T>, f : T -> Observable<R> ) {
		return merge( map( observable, f ) );
	}

	public static function fromSignal<T>( signal : Signal<T> ) : Observable<T> {
		var observable = Observable.create( ( observer ) -> {
			var cb = ( value ) -> observer.on_next( value );
			signal.add( cb );

			return Subscription.create(() -> signal.remove( cb ) );
		} );

		return observable;
	}
}
