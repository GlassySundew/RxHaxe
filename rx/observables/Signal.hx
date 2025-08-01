package rx.observables;

import rx.observers.IObserver;
import rx.disposables.ISubscription;

class Signal<T> extends Observable<T> {

	final signal : signals.Signal1<T>;

	public function new( signal : signals.Signal1<T> ) {
		super();
		this.signal = signal;
	}

	override public function subscribe( observer : IObserver<T> ) : ISubscription {
		var cb = ( value : T ) -> observer.on_next( value );
		signal.add( cb );

		return Subscription.create(() -> {
			signal.remove( cb );
		} );
	}
}
