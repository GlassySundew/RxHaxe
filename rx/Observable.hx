package rx;

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

// type +'a observable = 'a observer -> subscription
/*Internal module. (see Rx.Observable)
 *
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/Observable.java
 */
class Observable<T> implements IObservable<T> {

	public function new() {}

	public function subscribe( observer : IObserver<T> ) : ISubscription {
		return Subscription.empty();
	}
	public static var currentThread : CurrentThread = new CurrentThread();
	public static var newThread : NewThread = new NewThread();
	public static var immediate : Immediate = new Immediate();
	public static var test : Test = new Test();

	static public function empty<T>() return new Empty<T>();

	static public function error( e : String ) return new Error( e );

	static public function of_never() return new Never();

	static public function of_return<T>( v : T ) return new Return( v );

	static public function create<T>( f : IObserver<T> -> ISubscription ) {
		return new Create( f );
	}

	static public function defer<T>( _observableFactory : Void -> Observable<T> ) {
		return new Defer( _observableFactory );
	}

	static public function of<T>( __args : T ) : Observable<T> {
		return new Return( __args );
	}

	static public function of_enum<T>( __args : Array<T> ) : Observable<T> {
		return new Create( function ( observer : IObserver<T> ) {
			for ( i in 0...__args.length ) {
				observer.on_next( __args[i] );
			}
			observer.on_completed();
			return Subscription.empty();
		} );
	}

	static public function fromRange( ?initial : Null<Int>, ?limit : Null<Int>, ?step : Null<Int> ) {
		if ( limit == null && step == null ) {
			initial = 0;
			limit = 1;
		}
		if ( step == null ) {
			step = 1;
		}
		return Observable.create( function ( observer : IObserver<Int> ) {
			var i = initial;
			while ( i < limit ) {
				observer.on_next( i );
				trace( i );
				i += step;
			}
			observer.on_completed();
			return Subscription.empty();
		} );
	}

	public function find( comparer : Null<T -> Bool> ) {
		return new Find( this, comparer );
	}

	public function filter( comparer : Null<T -> Bool> ) {
		return new Filter( this, comparer );
	}

	public function distinctUntilChanged( ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new DistinctUntilChanged( this, comparer );
	}

	public function distinct( ?comparer : Null<T -> T -> Bool> ) {
		if ( comparer == null ) comparer = function ( a, b ) return a == b;
		return new Distinct( this, comparer );
	}

	public function delay( source : Observable<T>, dueTime : Float, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Delay( source, haxe.Timer.stamp() + dueTime, scheduler );
	}

	public function timestamp( source : Observable<T>, ?scheduler : Null<IScheduler> ) {
		if ( scheduler == null ) scheduler = Scheduler.timeBasedOperations;
		return new Timestamp( source, scheduler );
	}

	public function scan<R>( seed : Null<R>, accumulator : R -> T -> R ) {
		return new Scan( this, seed, accumulator );
	}

	public function last( ?source : Null<T> ) {
		return new Last( this, source );
	}

	public function first( ?source : Null<T> ) {
		return new First( this, source );
	}

	public function defaultIfEmpty( source : T ) {
		return new DefaultIfEmpty( this, source );
	}

	public function contains( source : T ) {
		return new Contains( this, function ( v ) return v == source );
	}

	public function concat( source : Array<Observable<T>> ) {
		return new Concat( [this].concat( source ) );
	}

	public function combineLatest<R>( source : Array<Observable<T>>, combinator : Array<T> -> R ) {
		return new CombineLatest( [this].concat( source ), combinator );
	}

	public function of_catch( errorHandler : String -> Observable<T> ) {
		return new Catch( this, errorHandler );
	}

	public function bufferCount( count : Int ) {
		return new BufferCount( this, count );
	}

	public function observe( fun : T -> Void ) {
		return this.subscribe( Observer.create( null, null, fun ) );
	}

	public function amb( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new Amb( observable1, observable2 );
	}

	public function average( observable : Observable<T> ) {
		return new Average( observable );
	}

	public function materialize() {
		return new Materialize( this );
	}

	public function length( observable : Observable<T> ) {
		return new Length( observable );
	}

	public function skip( n : Int ) {
		return new Skip( this, n );
	}

	public function skip_until( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new SkipUntil( observable1, observable2 );
	}

	public function take( n : Int ) {
		return new Take( this, n );
	}

	public function take_until( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new TakeUntil( observable1, observable2 );
	}

	public function take_last( n : Int ) {
		return new TakeLast( this, n );
	}

	public function single( observable : Observable<T> ) {
		return new Single( observable );
	}

	public function append( observable1 : Observable<T>, observable2 : Observable<T> ) {
		return new Append( observable1, observable2 );
	}

	public function map<R>( f : T -> R ) {
		return new Map( this, f );
	}

	public function bind<R>( f : T -> Observable<R> ) {
		return ObservableFactory.merge( map( f ) );
	}
}
