export declare const ErrorKind: {
    Roblox: 0,
    Validation: 1,
    Migration: 2,
    RaceCondition: 3,
}

export declare type Error = {
    Kind: typeof ErrorKind,
    Message: string,
}

export declare type SchemaMigration = (old: any) => any;

export declare type SchemaValidator<T> = (data: T | unknown) => boolean;

export declare interface CollectionOptions<T> {
    Name: string;
    Scope?: string;
    Default: T;
    Validate: SchemaValidator<T>;
    Migrations?: SchemaMigration[];
    MaxRetries?: number;
    RetryDelaySeconds?: number;
}

export declare class Collection<T> {
    private constructor();
    
    public Select(key: string): T | undefined;
    public Update(key: string, data: T, userIds?: number[]): boolean;
}

export declare const Spaceship: {
    CreateCollection<T>(options: CollectionOptions<T>): Collection<T>;
};
