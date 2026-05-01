export declare type CollectionMigration = (old: any) => any;

export declare type CollectionValidator<T> = (data: T) => boolean;

export declare interface CollectionOptions<T> {
    Name: string;
    Default: T;
    Validate: CollectionValidator<T>;
    Scope?: string;
    Migrations?: CollectionMigration[];
    MaxRetries?: number;
    RetryDelaySeconds?: number;
}

export declare class Collection<T> {
    public constructor(options: CollectionOptions<T>);

    public Select(key: string): T | undefined;
    public Update(key: string, data: T, userIds?: number[]): T | undefined;
}

export declare const Spaceship: {
    CreateCollection<T>(options: CollectionOptions<T>): Collection<T>;
};
